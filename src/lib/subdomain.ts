import { createServerComponentClient } from './supabase'
import { Church, SubdomainInfo } from './types'

export function extractSubdomain(host: string): string | null {
  if (!host) return null
  
  const mainDomain = process.env.NEXT_PUBLIC_MAIN_DOMAIN || 'localhost:3000'
  
  // Remove port if present for local development
  const cleanHost = host.split(':')[0]
  const cleanMainDomain = mainDomain.split(':')[0]
  
  // For localhost development
  if (cleanHost === cleanMainDomain || cleanHost === 'localhost') {
    return null
  }
  
  // Extract subdomain
  const parts = cleanHost.split('.')
  const mainParts = cleanMainDomain.split('.')
  
  // If we have more parts than the main domain, we have a subdomain
  if (parts.length > mainParts.length) {
    return parts[0]
  }
  
  return null
}

export async function getChurchBySubdomain(subdomain: string): Promise<Church | null> {
  if (!subdomain) return null
  
  try {
    const supabase = createServerComponentClient()
    
    const { data: church, error } = await supabase
      .from('churches')
      .select('*')
      .eq('slug', subdomain)
      .eq('is_active', true)
      .single()
    
    if (error || !church) {
      return null
    }
    
    return church as Church
  } catch (error) {
    console.error('Error fetching church by subdomain:', error)
    return null
  }
}

export async function resolveSubdomain(host: string): Promise<SubdomainInfo> {
  const subdomain = extractSubdomain(host)
  
  if (!subdomain) {
    return {
      slug: '',
      church: null,
      isValid: false
    }
  }
  
  const church = await getChurchBySubdomain(subdomain)
  
  return {
    slug: subdomain,
    church,
    isValid: !!church
  }
}

export function generateSubdomainUrl(slug: string): string {
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'
  const url = new URL(baseUrl)
  
  if (process.env.NODE_ENV === 'development') {
    // For local development, we'll use a different approach
    return `${url.protocol}//${slug}.${url.host}`
  }
  
  // For production
  return `https://${slug}.${url.host}`
}

export function isMainDomain(host: string): boolean {
  const subdomain = extractSubdomain(host)
  return !subdomain
}