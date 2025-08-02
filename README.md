# ChurchConnect - Church Management SaaS

A modern, comprehensive Church Management System built for UK churches. This SaaS application enables churches to manage their parishioner database with multi-tenant architecture, role-based access control, and beautiful, responsive design.

## 🌟 Features

### Multi-Tenant Architecture
- **Subdomain-based tenancy** - Each church gets their own subdomain (e.g., `stmarys.churchconnect.com`)
- **Custom branding** - Churches can customize their colors, logos, and themes
- **Isolated data** - Complete data separation between churches

### Role-Based Access Control
- **Super Admin** - Platform management, church onboarding, system monitoring
- **Church Admin** - Parishioner management, church settings, branding control
- **Parishioner** - Profile management, contact information updates

### Core Functionality
- **Church Registration** - Self-service church onboarding with admin setup
- **Parishioner Management** - Complete member database with family relationships
- **Profile Management** - Contact details, emergency contacts, ministry involvement
- **Secure Authentication** - Powered by Supabase Auth with email verification
- **Modern UI** - Professional, responsive design with Tailwind CSS

## 🚀 Tech Stack

- **Frontend**: Next.js 14, TypeScript, Tailwind CSS
- **Backend**: Next.js API Routes, Supabase
- **Database**: PostgreSQL (via Supabase)
- **Authentication**: Supabase Auth
- **UI Components**: Radix UI, Lucide React
- **Styling**: Tailwind CSS, Custom Design System

## 📋 Prerequisites

- Node.js 18+ installed
- Supabase account and project
- Git

## 🛠️ Setup Instructions

### 1. Clone the Repository

\`\`\`bash
git clone <repository-url>
cd church-management-saas
\`\`\`

### 2. Install Dependencies

\`\`\`bash
npm install
\`\`\`

### 3. Configure Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to Settings > API to get your keys
3. Copy `.env.local.example` to `.env.local` and update:

\`\`\`env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-supabase-service-role-key

# App Configuration
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_MAIN_DOMAIN=localhost:3000

# JWT Secret for additional security
JWT_SECRET=your-jwt-secret-key
\`\`\`

### 4. Set Up Database Schema

1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy and paste the content from `supabase-schema.sql`
4. Run the SQL script to create all tables, policies, and functions

### 5. Configure Authentication

In your Supabase dashboard:
1. Go to Authentication > Settings
2. Set up email templates for verification and password reset
3. Configure redirect URLs for your domain

### 6. Run the Application

\`\`\`bash
npm run dev
\`\`\`

The application will be available at `http://localhost:3000`

## 🏗️ Project Structure

\`\`\`
src/
├── app/                          # Next.js App Router
│   ├── api/                      # API routes
│   │   └── churches/
│   │       └── register/         # Church registration endpoint
│   ├── auth/                     # Authentication pages
│   ├── tenant/                   # Tenant-specific pages
│   │   └── [slug]/               # Dynamic church pages
│   ├── register-church/          # Church registration form
│   ├── registration-success/     # Success page
│   ├── globals.css              # Global styles
│   ├── layout.tsx               # Root layout
│   └── page.tsx                 # Homepage
├── components/
│   └── ui/                      # Reusable UI components
├── lib/
│   ├── supabase.ts             # Supabase client configuration
│   ├── subdomain.ts            # Subdomain utilities
│   ├── types.ts                # TypeScript types
│   └── utils.ts                # Utility functions
├── middleware.ts               # Next.js middleware for routing
└── ...
\`\`\`

## 🔐 Database Schema

### Core Tables
- **users** - Extends Supabase auth.users with role information
- **churches** - Church information and branding
- **church_admins** - Links users to churches as administrators
- **parishioners** - Detailed parishioner information

### Security Features
- Row Level Security (RLS) enabled on all tables
- Role-based access policies
- Multi-tenant data isolation
- Secure authentication flow

## 🎨 Design System

The application uses a custom design system built with Tailwind CSS:

- **Colors**: Professional blue palette with church-specific theming
- **Typography**: Clean, readable fonts optimized for all devices
- **Components**: Consistent, accessible UI components
- **Responsive**: Mobile-first design that works on all screen sizes

## 🚀 Deployment

### Vercel (Recommended)

1. Connect your GitHub repository to Vercel
2. Set environment variables in Vercel dashboard
3. Deploy automatically on every push

### Manual Deployment

\`\`\`bash
npm run build
npm start
\`\`\`

## 🔧 Development

### Available Scripts

- \`npm run dev\` - Start development server
- \`npm run build\` - Build for production
- \`npm run start\` - Start production server
- \`npm run lint\` - Run ESLint

### Testing Subdomains Locally

For local development with subdomains:

1. Edit your `/etc/hosts` file (Linux/Mac) or `C:\Windows\System32\drivers\etc\hosts` (Windows)
2. Add entries like:
   \`\`\`
   127.0.0.1 localhost
   127.0.0.1 stmarys.localhost
   127.0.0.1 stpauls.localhost
   \`\`\`
3. Access your tenant sites at `http://stmarys.localhost:3000`

## 📖 Usage

### Church Registration Flow

1. Visit the main site and click "Register Your Church"
2. Fill in church details and administrator information
3. Church admin receives verification email
4. Admin verifies email and sets up password
5. Church gets custom subdomain and branding

### Admin Features

Church administrators can:
- Manage parishioner database
- Update church branding and information
- View member profiles and contact details
- Export member data
- Manage church settings

### Parishioner Features

Parishioners can:
- Create and update their profiles
- Manage contact information
- Update emergency contacts
- Track ministry involvement
- Reset passwords independently

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (\`git checkout -b feature/amazing-feature\`)
3. Commit your changes (\`git commit -m 'Add some amazing feature'\`)
4. Push to the branch (\`git push origin feature/amazing-feature\`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Email: support@churchconnect.uk
- Documentation: [Link to docs]
- Issues: GitHub Issues page

## 🛣️ Roadmap

- [ ] Email notifications and newsletters
- [ ] Event management system
- [ ] Donation tracking
- [ ] Mobile app (React Native)
- [ ] Advanced reporting and analytics
- [ ] Integration with payment processors
- [ ] Multi-language support

---

**Built with ❤️ for UK Churches**
