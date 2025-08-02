export interface Church {
  id: string
  name: string
  slug: string // For subdomain routing
  description?: string
  address?: string
  phone?: string
  email: string
  website?: string
  logo_url?: string
  primary_color?: string
  secondary_color?: string
  created_at: string
  updated_at: string
  is_active: boolean
  subscription_status: 'trial' | 'active' | 'suspended' | 'cancelled'
}

export interface ChurchAdmin {
  id: string
  church_id: string
  user_id: string
  created_at: string
  church?: Church
}

export interface Parishioner {
  id: string
  church_id: string
  user_id: string
  first_name: string
  last_name: string
  date_of_birth?: string
  phone?: string
  address?: string
  emergency_contact_name?: string
  emergency_contact_phone?: string
  ministry_involvement?: string
  family_relationships?: string
  notes?: string
  is_active: boolean
  created_at: string
  updated_at: string
  church?: Church
}

export interface User {
  id: string
  email: string
  role: 'super_admin' | 'church_admin' | 'parishioner'
  avatar_url?: string
  created_at: string
  updated_at: string
}

export interface Profile extends User {
  parishioner?: Parishioner
  church_admin?: ChurchAdmin
}

export type UserRole = 'super_admin' | 'church_admin' | 'parishioner'

export interface ChurchRegistration {
  name: string
  email: string
  phone?: string
  address?: string
  website?: string
  description?: string
  admin_first_name: string
  admin_last_name: string
  admin_email: string
}

export interface SubdomainInfo {
  slug: string
  church: Church | null
  isValid: boolean
}