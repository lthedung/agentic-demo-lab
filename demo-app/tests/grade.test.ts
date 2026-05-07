import { describe, expect, it } from 'vitest';
import { classifyGrade } from '../src/grade';

describe('classifyGrade', () => {
  it('returns excellent for scores from 90 to 100', () => {
    expect(classifyGrade(95)).toBe('excellent');
  });

  it('returns good for scores from 75 to 89', () => {
    expect(classifyGrade(82)).toBe('good');
  });

  it('returns passed for scores from 50 to 74', () => {
    expect(classifyGrade(60)).toBe('passed');
  });

  it('returns failed for scores below 50', () => {
    expect(classifyGrade(42)).toBe('failed');
  });

  it('rejects scores outside the valid range', () => {
    expect(() => classifyGrade(120)).toThrow('Score must be between 0 and 100');
    expect(() => classifyGrade(-1)).toThrow('Score must be between 0 and 100');
  });
});
