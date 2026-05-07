export type OrderItem = {
  name: string;
  quantity: number;
  unitPrice: number;
};

export type OrderInput = {
  items: OrderItem[];
  couponCode?: string;
};

export type OrderTotal = {
  subtotal: number;
  discount: number;
  shipping: number;
  total: number;
};

export function calculateOrderTotal(order: OrderInput): OrderTotal {
  if (order.items.length === 0) {
    throw new Error('Order must contain at least one item');
  }

  const subtotal = order.items.reduce((sum, item) => sum + item.quantity * item.unitPrice, 0);
  const discount = order.couponCode === 'SESSION3' ? subtotal * 0.1 : 0;
  const shipping = subtotal >= 100 ? 0 : 5;
  const total = subtotal - discount + shipping;

  return { subtotal, discount, shipping, total };
}
