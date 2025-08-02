import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { extractSubdomain, isMainDomain } from './lib/subdomain'

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl
  const host = request.headers.get('host') || ''
  
  // Extract subdomain from the host
  const subdomain = extractSubdomain(host)
  
  // If this is the main domain (no subdomain), proceed normally
  if (isMainDomain(host)) {
    // Redirect to super admin or main landing page
    return NextResponse.next()
  }
  
  // If we have a subdomain, rewrite to the tenant-specific route
  if (subdomain) {
    // Rewrite to the tenant route with the subdomain as a parameter
    const url = request.nextUrl.clone()
    url.pathname = `/tenant/${subdomain}${pathname}`
    
    return NextResponse.rewrite(url)
  }
  
  // If subdomain is invalid or not found, redirect to main domain
  const mainDomain = process.env.NEXT_PUBLIC_MAIN_DOMAIN || 'localhost:3000'
  const protocol = process.env.NODE_ENV === 'development' ? 'http' : 'https'
  const redirectUrl = `${protocol}://${mainDomain}`
  
  return NextResponse.redirect(redirectUrl)
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public assets
     */
    '/((?!api|_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}