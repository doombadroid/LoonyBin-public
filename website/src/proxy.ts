import { NextResponse, type NextRequest } from "next/server";
import { jwtVerify } from "jose";

// Site-wide Steam-login gate. Optimistic check (per Next docs): verify the
// session cookie's signature here and redirect to /login if absent/invalid.
// Authoritative session use still happens in pages via getSession().
const COOKIE = "lb_session";

function key(): Uint8Array {
  return new TextEncoder().encode(process.env.SESSION_SECRET ?? "");
}

export async function proxy(req: NextRequest) {
  // Canonicalize: bare apex -> www (the cert covers both; www is the SITE_URL).
  const host = (req.headers.get("host") || "").split(":")[0].toLowerCase();
  if (host === "projectloonybin.com") {
    return NextResponse.redirect(
      `https://www.projectloonybin.com${req.nextUrl.pathname}${req.nextUrl.search}`,
      308
    );
  }

  const token = req.cookies.get(COOKIE)?.value;
  let valid = false;
  if (token) {
    try {
      await jwtVerify(token, key());
      valid = true;
    } catch {
      valid = false;
    }
  }
  if (valid) return NextResponse.next();

  const url = req.nextUrl.clone();
  url.pathname = "/login";
  url.search = "";
  const res = NextResponse.redirect(url);
  if (token) res.cookies.delete(COOKIE); // drop a stale/invalid cookie
  return res;
}

// Run on everything except the login page, the auth endpoints, Next internals,
// the favicon, and any file-with-extension (static assets).
export const config = {
  matcher: ["/((?!api/auth|login|_next|favicon.ico|.*\\.[\\w]+$).*)"],
};
