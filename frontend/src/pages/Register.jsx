import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom'; // Added useNavigate
import AuthLayout from '../components/AuthLayout';
import TextField from '../components/TextField';
import Button from '../components/Button';

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function validate({ name, email, password, confirmPassword }) {
  const errors = {};
  if (!name.trim()) errors.name = 'Full name is required';
  if (!email.trim()) errors.email = 'Email is required';
  else if (!EMAIL_PATTERN.test(email)) errors.email = 'Enter a valid email address';
  if (password.length < 8) errors.password = 'Password must be at least 8 characters';
  if (confirmPassword !== password) errors.confirmPassword = 'Passwords do not match';
  return errors;
}

function Register() {
  const navigate = useNavigate();
  const [form, setForm] = useState({ name: '', email: '', password: '', confirmPassword: '' });
  const [errors, setErrors] = useState({});
  const [successMessage, setSuccessMessage] = useState(''); // Added success state
  const [apiError, setApiError] = useState('');

  function handleChange(e) {
    setForm({ ...form, [e.target.name]: e.target.value });
    setErrors({ ...errors, [e.target.name]: undefined });
    setApiError('');
  }

  async function handleSubmit(e) {
    e.preventDefault();

    const found = validate(form);
    setErrors(found);

    if (Object.keys(found).length > 0) return;

    try {
      const response = await fetch(
        'http://localhost:5000/api/auth/register',
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            name: form.name,
            email: form.email,
            password: form.password,
          }),
        }
      );

      const data = await response.json();

      if (!response.ok) {
        setApiError(data.message || 'Registration failed');
        return;
      }

      // Trigger success popup/banner
      setSuccessMessage('Account created successfully! Redirecting to login...');
      
      setTimeout(() => {
        navigate('/login');
      }, 2000);

    } catch (error) {
      console.error('Registration failed:', error);
      setApiError('Something went wrong. Please try again.');
    }
  }

  return (
    <AuthLayout title="Create an account" subtitle="Register as a student to borrow lab equipment">
      {/* Success Popup / Banner */}
      {successMessage && (
        <div className="mb-4 rounded-xl bg-emerald-500/10 border border-emerald-500/20 p-4 text-center text-sm font-medium text-emerald-400 animate-fade-in">
          {successMessage}
        </div>
      )}

      {/* API Error Banner */}
      {apiError && (
        <div className="mb-4 rounded-xl bg-rose-500/10 border border-rose-500/20 p-4 text-center text-sm font-medium text-rose-400">
          {apiError}
        </div>
      )}

      <form onSubmit={handleSubmit} noValidate className="flex flex-col gap-5">
        <TextField
          dark
          id="name"
          name="name"
          label="Full name"
          placeholder="Jane Doe"
          autoComplete="name"
          value={form.name}
          onChange={handleChange}
          error={errors.name}
        />
        <TextField
          dark
          id="email"
          name="email"
          type="email"
          label="Email"
          placeholder="you@university.edu"
          autoComplete="email"
          value={form.email}
          onChange={handleChange}
          error={errors.email}
        />
        <TextField
          dark
          id="password"
          name="password"
          type="password"
          label="Password"
          placeholder="At least 8 characters"
          autoComplete="new-password"
          value={form.password}
          onChange={handleChange}
          error={errors.password}
        />
        <TextField
          dark
          id="confirmPassword"
          name="confirmPassword"
          type="password"
          label="Confirm password"
          autoComplete="new-password"
          value={form.confirmPassword}
          onChange={handleChange}
          error={errors.confirmPassword}
        />
        <Button type="submit" className="mt-2 w-full py-3">
          Create account
        </Button>
      </form>

      <p className="mt-6 text-center text-sm text-white/70">
        Already have an account?{' '}
        <Link to="/login" className="font-semibold text-indigo-300 hover:text-indigo-200">
          Sign in
        </Link>
      </p>
    </AuthLayout>
  );
}

export default Register;