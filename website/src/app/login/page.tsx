import { redirect } from "next/navigation";
import { getSession } from "@/lib/session";

export const dynamic = "force-dynamic";
export const metadata = { title: "Sign in" };

const SITE = process.env.NEXT_PUBLIC_SITE_NAME ?? "LooneyBin";

export default async function LoginPage() {
  const session = await getSession();
  if (session) redirect("/");

  return (
    <div className="min-h-screen flex items-center justify-center px-4 bg-gradient-to-b from-gray-950 via-gray-900 to-gray-950">
      <div className="w-full max-w-md">
        <div className="bg-gray-900 border border-th-700/30 rounded-2xl p-8 sm:p-10 shadow-2xl text-center">
          <div className="mx-auto mb-6 w-16 h-16 rounded-2xl bg-th-600/20 border border-th-500/30 flex items-center justify-center">
            <span className="brand-font text-2xl text-th-400">LB</span>
          </div>
          <h1 className="brand-font text-4xl text-white tracking-wide">{SITE.toUpperCase()}</h1>
          <p className="text-gray-400 mt-2 text-sm">
            Altis Life — player stats, gangs, leaderboards &amp; more.
          </p>

          <a
            href="/api/auth/login"
            className="mt-8 w-full inline-flex items-center justify-center gap-3 px-5 py-3 rounded-xl bg-[#1b2838] hover:bg-[#2a3f5a] border border-[#66c0f4]/30 text-white font-semibold transition"
          >
            <svg viewBox="0 0 24 24" className="w-5 h-5" fill="currentColor" aria-hidden="true">
              <path d="M11.98 0C5.66 0 .48 4.88.02 11.06l6.44 2.66a3.4 3.4 0 0 1 1.9-.59l2.87-4.16v-.06a4.54 4.54 0 0 1 4.54-4.54 4.54 4.54 0 0 1 4.53 4.54 4.54 4.54 0 0 1-4.53 4.54h-.11l-4.1 2.93a3.4 3.4 0 0 1-6.76.55L.46 14.5A12 12 0 0 0 11.98 24c6.62 0 11.99-5.37 11.99-12S18.6 0 11.98 0zM7.54 18.21l-1.47-.61a2.55 2.55 0 0 0 1.32 1.26 2.56 2.56 0 0 0 3.34-1.38 2.56 2.56 0 0 0 0-1.96 2.56 2.56 0 0 0-1.38-1.39 2.56 2.56 0 0 0-1.95-.02l1.52.63a1.88 1.88 0 0 1-1.44 3.47zm10.49-7.62a3.03 3.03 0 0 0 3.02-3.02 3.03 3.03 0 0 0-3.02-3.03 3.03 3.03 0 0 0-3.02 3.03 3.03 3.03 0 0 0 3.02 3.02zm0-4.54a1.52 1.52 0 0 1 0 3.03 1.52 1.52 0 0 1 0-3.03z" />
            </svg>
            Sign in with Steam
          </a>

          <p className="text-gray-600 text-xs mt-6">
            You must sign in with Steam to view stats, gangs, tickets and more.
          </p>
        </div>
        <p className="text-center text-gray-700 text-xs mt-4">
          We only read your public Steam ID. No password is shared with us.
        </p>
      </div>
    </div>
  );
}
