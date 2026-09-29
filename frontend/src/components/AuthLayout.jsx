import bg from '../assets/bg1.jpg';

// Shared frame for the login and register pages: background image + frosted card.
function AuthLayout({ title, subtitle, children }) {
  return (
    <div
      className="flex min-h-screen w-full items-center justify-center bg-cover bg-center px-4 py-10"
      style={{ backgroundImage: `url(${bg})` }}
    >
      <div className="w-full max-w-md rounded-3xl border border-white/20 bg-gray-900/40 p-6 shadow-2xl backdrop-blur-2xl sm:p-8">
        <div className="mb-8 text-center">
          <p className="text-sm font-semibold tracking-wide text-indigo-300 uppercase">Lab Equipment Manager</p>
          <h1 className="mt-2 text-3xl font-bold text-white">{title}</h1>
          {subtitle && <p className="mt-2 text-sm text-white/70">{subtitle}</p>}
        </div>
        {children}
      </div>
    </div>
  );
}

export default AuthLayout;
