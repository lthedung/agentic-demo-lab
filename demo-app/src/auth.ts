export type LoginInput = {
  email: string;
  password: string;
};

export type ValidationResult = {
  valid: boolean;
  errors: string[];
};

export function validateLoginInput(input: LoginInput): ValidationResult {
  const errors: string[] = [];

  if (!input.email.includes('@')) {
    errors.push('Email is invalid');
  }

  if (input.password.length < 8) {
    errors.push('Password must have at least 8 characters');
  }

  return {
    valid: errors.length === 0,
    errors
  };
}
