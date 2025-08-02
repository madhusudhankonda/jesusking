-- Enable RLS (Row Level Security)
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret-key';

-- Create custom types
CREATE TYPE user_role AS ENUM ('super_admin', 'church_admin', 'parishioner');
CREATE TYPE subscription_status AS ENUM ('trial', 'active', 'suspended', 'cancelled');

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    role user_role NOT NULL DEFAULT 'parishioner',
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Churches table
CREATE TABLE public.churches (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL, -- For subdomain routing
    description TEXT,
    address TEXT,
    phone TEXT,
    email TEXT NOT NULL,
    website TEXT,
    logo_url TEXT,
    primary_color TEXT DEFAULT '#3B82F6',
    secondary_color TEXT DEFAULT '#1E40AF',
    is_active BOOLEAN DEFAULT true,
    subscription_status subscription_status DEFAULT 'trial',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Church admins table (relationship between users and churches)
CREATE TABLE public.church_admins (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    church_id UUID REFERENCES public.churches(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(church_id, user_id)
);

-- Parishioners table
CREATE TABLE public.parishioners (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    church_id UUID REFERENCES public.churches(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    date_of_birth DATE,
    phone TEXT,
    address TEXT,
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    ministry_involvement TEXT,
    family_relationships TEXT,
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(church_id, user_id)
);

-- Indexes for performance
CREATE INDEX idx_churches_slug ON public.churches(slug);
CREATE INDEX idx_churches_active ON public.churches(is_active);
CREATE INDEX idx_church_admins_church_id ON public.church_admins(church_id);
CREATE INDEX idx_church_admins_user_id ON public.church_admins(user_id);
CREATE INDEX idx_parishioners_church_id ON public.parishioners(church_id);
CREATE INDEX idx_parishioners_user_id ON public.parishioners(user_id);
CREATE INDEX idx_parishioners_active ON public.parishioners(is_active);
CREATE INDEX idx_users_role ON public.users(role);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.churches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.church_admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parishioners ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users policies
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Super admins can view all users" ON public.users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'super_admin'
        )
    );

-- Churches policies
CREATE POLICY "Churches are viewable by their members" ON public.churches
    FOR SELECT USING (
        id IN (
            SELECT church_id FROM public.church_admins WHERE user_id = auth.uid()
            UNION
            SELECT church_id FROM public.parishioners WHERE user_id = auth.uid()
        )
        OR EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'super_admin'
        )
    );

CREATE POLICY "Super admins can manage all churches" ON public.churches
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'super_admin'
        )
    );

CREATE POLICY "Church admins can update their church" ON public.churches
    FOR UPDATE USING (
        id IN (
            SELECT church_id FROM public.church_admins WHERE user_id = auth.uid()
        )
    );

-- Church admins policies
CREATE POLICY "Church admins viewable by super admins and self" ON public.church_admins
    FOR SELECT USING (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'super_admin'
        )
    );

CREATE POLICY "Super admins can manage church admins" ON public.church_admins
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'super_admin'
        )
    );

-- Parishioners policies
CREATE POLICY "Parishioners can view their own record" ON public.parishioners
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Parishioners can update their own record" ON public.parishioners
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Church admins can view their church's parishioners" ON public.parishioners
    FOR SELECT USING (
        church_id IN (
            SELECT church_id FROM public.church_admins WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Church admins can manage their church's parishioners" ON public.parishioners
    FOR ALL USING (
        church_id IN (
            SELECT church_id FROM public.church_admins WHERE user_id = auth.uid()
        )
        OR EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'super_admin'
        )
    );

-- Functions and triggers for updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

CREATE TRIGGER update_churches_updated_at BEFORE UPDATE ON public.churches
    FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

CREATE TRIGGER update_parishioners_updated_at BEFORE UPDATE ON public.parishioners
    FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- Function to handle new user registration
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, role)
    VALUES (NEW.id, NEW.email, 'parishioner');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user registration
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Function to create church with slug
CREATE OR REPLACE FUNCTION public.create_church_slug(church_name TEXT)
RETURNS TEXT AS $$
DECLARE
    base_slug TEXT;
    final_slug TEXT;
    counter INTEGER := 0;
BEGIN
    -- Create base slug from church name
    base_slug := lower(regexp_replace(church_name, '[^a-zA-Z0-9\s]', '', 'g'));
    base_slug := regexp_replace(base_slug, '\s+', '-', 'g');
    final_slug := base_slug;
    
    -- Check for uniqueness and append number if needed
    WHILE EXISTS (SELECT 1 FROM public.churches WHERE slug = final_slug) LOOP
        counter := counter + 1;
        final_slug := base_slug || '-' || counter;
    END LOOP;
    
    RETURN final_slug;
END;
$$ LANGUAGE plpgsql;