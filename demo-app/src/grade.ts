export type Grade = 'excellent' | 'good' | 'passed' | 'failed';

export function classifyGrade(score: number): Grade {
  if (score < 0 || score > 100) {
    throw new Error('Score must be between 0 and 100');
  }

  if (score >= 90) {
    return 'excellent';
  }

  if (score >= 75) {
    return 'good';
  }

  if (score >= 50) {
    return 'passed';
  }

  return 'failed';
}
