import { describe, expect, it } from 'vitest';
import { calculateOrderTotal } from '../src/order';

describe('calculateOrderTotal', () => {
  it('adds standard shipping for small orders', () => {
    expect(
      calculateOrderTotal({
        items: [
          { name: 'Book', quantity: 1, unitPrice: 20 },
          { name: 'Pen', quantity: 2, unitPrice: 5 }
        ]
      })
    ).toEqual({ subtotal: 30, discount: 0, shipping: 5, total: 35 });
  });

  it('applies free shipping for orders from 100', () => {
    expect(
      calculateOrderTotal({
        items: [{ name: 'Keyboard', quantity: 1, unitPrice: 120 }]
      })
    ).toEqual({ subtotal: 120, discount: 0, shipping: 0, total: 120 });
  });

  it('applies 10 percent discount before shipping when coupon is valid', () => {
    expect(
      calculateOrderTotal({
        items: [{ name: 'Monitor', quantity: 1, unitPrice: 200 }],
        couponCode: 'SESSION3'
      })
    ).toEqual({ subtotal: 200, discount: 20, shipping: 0, total: 180 });
  });

  it('rejects empty carts', () => {
    expect(() => calculateOrderTotal({ items: [] })).toThrow('Order must contain at least one item');
  });
});
