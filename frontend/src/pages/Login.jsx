import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom'; // Added useNavigate
import AuthLayout from '../components/AuthLayout';
import TextField from '../components/TextField';
import Button from '../components/Button';

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function validate({ email, password }) {
  const errors = {};

  if (!email.trim()) {
    errors.email = 'Email is required';
  } else if (!EMAIL_PATTERN.test(email)) {
    errors.email = 'Enter a valid Email Address';
  }

  if (!password) {
    errors.password = 'Password is required';
  }

  return errors;
}

function Login() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    email: '',
    password: ''
  });

  const [errors, setErrors] = useState({});
  const [successMessage, setSuccessMessage] = useState(''); // Added success state
  const [apiError, setApiError] = useState('');

  function handleChange(e) {
    setForm({
      ...form,
      [e.target.name]: e.target.value
    });

    setErrors({
      ...errors,
      [e.target.name]: undefined
    });
    setApiError('');
  }

  async function handleSubmit(e) {
    e.preventDefault();

    const found = validate(form);
    setErrors(found);

    if (Object.keys(found).length > 0) {
      return;
    }

    try {
      const response = await fetch(
        'http://localhost:5000/api/auth/login',
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            email: form.email,
            password: form.password
          })
        }
      );

      const data = await response.json();

      if (!response.ok) {
        setApiError(data.message || 'Invalid email or password');
        return;
      }

      // Trigger success state and redirect to dashboard/home
      setSuccessMessage('Login successful! Redirecting...');
      
      // Save token/user to localStorage if needed
      // localStorage.setItem('token', data.token);

      setTimeout(() => {
        navigate('/dashboard'); // Change to your target route
      }, 1500);

    } catch (error) {
      console.error('Login request failed:', error);
      setApiError('Something went wrong. Please check your connection.');
    }
  }

  return (
    <AuthLayout title="Welcome back" subtitle="Sign in to manage and borrow lab equipment">
      {/* Success Popup / Banner */}
      {successMessage && (
        <div className="mb-4 rounded-xl bg-emerald-500/10 border border-emerald-500/20 p-4 text-center text-sm font-medium text-emerald-400">
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
          placeholder="••••••••"
          autoComplete="current-password"
          value={form.password}
          onChange={handleChange}
          error={errors.password}
        />
        <Button type="submit" className="mt-2 w-full py-3">
          Sign in
        </Button>
      </form>

      <p className="mt-6 text-center text-sm text-white/70">
        Don&apos;t have an account?{' '}
        <Link to="/register" className="font-semibold text-indigo-300 hover:text-indigo-200">
          Register
        </Link>
      </p>
    </AuthLayout>
  );
}

export default Login;