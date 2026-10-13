import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:serveease_pos/main.dart';
import 'package:serveease_pos/models/employee.dart';
import 'package:serveease_pos/models/menu_item.dart';
import 'package:serveease_pos/models/order_receipt.dart';
import 'package:serveease_pos/models/owner_account.dart';
import 'package:serveease_pos/state/app_state.dart';

void main() {
  testWidgets(
    'ServeEase POS launches and shows Access Screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ServeEaseApp());

      expect(find.text('A & A RESTAURANT POS'), findsOneWidget);
      expect(find.text('CASHIER'), findsOneWidget);
      expect(find.text('OWNER'), findsOneWidget);
    },
  );

  group('cashier credentials', () {
    test('accepts only a matching, active employee', () {
      final state = AppState();
      state.employees.clear();
      state.employees.add(Employee(
        id: 'CSH001',
        name: 'Juan Dela Cruz',
        role: 'Cashier',
        username: 'juan',
        password: 'secret123',
      ));

      expect(state.authenticateCashier('juan', 'secret123'), isNotNull);
      expect(state.authenticateCashier('juan', 'wrong'), isNull);
      expect(state.authenticateCashier('nobody', 'secret123'), isNull);

      state.employees.first.isActive = false;
      expect(state.authenticateCashier('juan', 'secret123'), isNull);

      state.employees.clear();
    });

    test('registerCashier rejects duplicate usernames and IDs', () {
      final state = AppState();
      state.employees.clear();

      expect(
        state.registerCashier(Employee(
          id: 'CSH001',
          name: 'A',
          role: 'Cashier',
          username: 'a',
          password: 'pw1234',
        )),
        isNull,
      );

      expect(
        state.registerCashier(Employee(
          id: 'CSH002',
          name: 'B',
          role: 'Cashier',
          username: 'a', // duplicate username
          password: 'pw1234',
        )),
        'That username is already taken',
      );

      expect(
        state.registerCashier(Employee(
          id: 'CSH001', // duplicate ID
          name: 'C',
          role: 'Cashier',
          username: 'c',
          password: 'pw1234',
        )),
        'That employee ID is already taken',
      );

      state.employees.clear();
    });
  });

  test('owner falls back to legacy credentials until an account exists', () {
    final state = AppState();
    state.ownerAccount = null;

    expect(state.authenticateOwner('enchang', 'enchang'), isTrue);
    expect(state.authenticateOwner('enchang', 'nope'), isFalse);

    state.registerOwner(OwnerAccount(
      fullName: 'Test Owner',
      username: 'boss',
      password: 'pw1234',
    ));

    // Once a real account exists the fallback stops working.
    expect(state.authenticateOwner('enchang', 'enchang'), isFalse);
    expect(state.authenticateOwner('boss', 'pw1234'), isTrue);

    state.ownerAccount = null;
  });

  test('a completed order is recorded and round-trips through JSON', () {
    final state = AppState();
    state.clearCart();
    state.orders.clear();

    state.addToCart(
      MenuItem(
        id: 'M1',
        name: 'Burger',
        category: 'Burgers',
        basePrice: 100,
        sizePrices: {'Medium': 100.0},
        imageUrl: '',
      ),
      'Medium',
      2,
      'no onions',
    );

    final receipt = state.completeCurrentOrder(
      hasDiscount: false,
      discountReason: '',
      discountIdType: '',
      discountIdNumber: '',
      customerName: 'Juan',
      discountNotes: '',
      discountPercent: 0,
      discountAmount: 0,
      totalAmount: 200,
      paymentMethod: 'Cash',
      amountPaid: 200,
      changeAmount: 0,
    );

    expect(state.orders.first, same(receipt));
    expect(state.currentCart, isEmpty);

    // This is the round trip that used to be dead code and never persisted.
    final restored = OrderReceipt.fromJson(
        jsonDecode(jsonEncode(receipt.toJson())) as Map<String, dynamic>);

    expect(restored.orderId, receipt.orderId);
    expect(restored.customerName, 'Juan');
    expect(restored.totalAmount, receipt.totalAmount);
    expect(restored.paymentMethod, 'Cash');
    expect(restored.items.length, receipt.items.length);
    expect(restored.items.first.quantity, 2);
    expect(restored.items.first.specialNotes, 'no onions');
    expect(restored.items.first.item.name, 'Burger');

    state.orders.clear();
    state.clearCart();
  });
}
