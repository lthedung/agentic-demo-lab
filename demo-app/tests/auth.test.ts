import { describe, expect, it } from 'vitest';
import { validateLoginInput } from '../src/auth';

describe('validateLoginInput', () => {
  it('accepts a valid email and password', () => {
    expect(validateLoginInput({ email: 'student@example.com', password: 'secret123' })).toEqual({
      valid: true,
      errors: []
    });
  });

  it('rejects invalid email addresses', () => {
    expect(validateLoginInput({ email: 'student', password: 'secret123' })).toEqual({
      valid: false,
      errors: ['Email is invalid']
    });
  });

  it('rejects short passwords', () => {
    expect(validateLoginInput({ email: 'student@example.com', password: '123' })).toEqual({
      valid: false,
      errors: ['Password must have at least 8 characters']
    });
  });

  it('returns all validation errors together', () => {
    expect(validateLoginInput({ email: 'student', password: '123' })).toEqual({
      valid: false,
      errors: ['Email is invalid', 'Password must have at least 8 characters']
    });
  });
});
