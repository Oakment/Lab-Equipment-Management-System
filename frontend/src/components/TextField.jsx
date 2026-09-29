// A labelled input with an optional error message underneath.
// `dark` switches to the translucent style used on the auth pages.
function TextField({ label, id, error, dark = false, ...props }) {
  const inputStyle = dark
    ? 'bg-white/10 text-white placeholder:text-white/50 ring-white/20 focus:ring-indigo-400'
    : 'bg-white text-slate-900 placeholder:text-slate-400 ring-slate-300 focus:ring-indigo-500';

  return (
    <div className="flex flex-col gap-1.5">
      <label htmlFor={id} className={`text-sm font-medium ${dark ? 'text-white/90' : 'text-slate-700'}`}>
        {label}
      </label>
      <input
        id={id}
        className={`w-full rounded-lg px-3.5 py-2.5 text-sm ring-1 outline-none focus:ring-2
          ${inputStyle} ${error ? 'ring-red-400' : ''}`}
        aria-invalid={Boolean(error)}
        {...props}
      />
      {error && <p className={`text-xs ${dark ? 'text-red-300' : 'text-red-600'}`}>{error}</p>}
    </div>
  );
}

export default TextField;
