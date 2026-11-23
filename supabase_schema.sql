-- =====================================================================
-- RAGS HEAVEN - COMPLETE SUPABASE DATABASE SETUP SCHEMA
-- Project: https://deaqdbsqcmnzlhghjbpj.supabase.co
-- Row Level Security (RLS) is disabled for all tables as requested.
-- =====================================================================

-- 1. Staff Accounts & Users Table
CREATE TABLE IF NOT EXISTS public.rh_users (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    role TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Employees Directory Table
CREATE TABLE IF NOT EXISTS public.employees (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    role TEXT NOT NULL,
    designation TEXT,
    phone TEXT,
    salary NUMERIC DEFAULT 0,
    username TEXT,
    status TEXT DEFAULT 'Active',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Attendance Records Table
CREATE TABLE IF NOT EXISTS public.attendance_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date DATE NOT NULL,
    employee_id TEXT NOT NULL,
    employee_name TEXT NOT NULL,
    role TEXT,
    status TEXT NOT NULL DEFAULT 'Present',
    in_time TEXT DEFAULT '08:30',
    out_time TEXT DEFAULT '17:30',
    hours_worked NUMERIC DEFAULT 8,
    overtime_hours NUMERIC DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_emp_date UNIQUE(employee_id, date)
);

-- 4. AB Grade Stock Table
CREATE TABLE IF NOT EXISTS public.ab_grade_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    location TEXT,
    category TEXT,
    pcs INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Customer Ready Stock Table
CREATE TABLE IF NOT EXISTS public.customer_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_name TEXT NOT NULL,
    name TEXT NOT NULL,
    category TEXT,
    qty INTEGER DEFAULT 0,
    rack TEXT,
    status TEXT DEFAULT 'Ready',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Grading Records Table
CREATE TABLE IF NOT EXISTS public.grading_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_name TEXT NOT NULL,
    lot_no TEXT,
    total_pcs INTEGER NOT NULL,
    grader_id TEXT,
    grader_name TEXT NOT NULL,
    categories_breakdown JSONB NOT NULL DEFAULT '[]'::jsonb,
    status TEXT DEFAULT 'Pending Review',
    checker_name TEXT,
    inspected_pcs INTEGER DEFAULT 0,
    errors_pcs INTEGER DEFAULT 0,
    accuracy_percent NUMERIC(5, 2),
    checker_notes TEXT,
    movement_status TEXT DEFAULT 'Not Moved',
    movement_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Custom Grading Categories Table
CREATE TABLE IF NOT EXISTS public.grading_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    color TEXT DEFAULT 'blue',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Petty Cash Table
CREATE TABLE IF NOT EXISTS public.petty_cash (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type TEXT NOT NULL,
    amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    description TEXT,
    by_whom TEXT,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    note TEXT,
    category TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Inventory Movements Audit Table
CREATE TABLE IF NOT EXISTS public.inventory_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_name TEXT NOT NULL,
    qty INTEGER NOT NULL,
    from_location TEXT,
    to_location TEXT,
    grader_name TEXT,
    checker_name TEXT,
    lot_no TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. Bells Register Table
CREATE TABLE IF NOT EXISTS public.bells (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_name TEXT,
    bell_weight NUMERIC(8,2) DEFAULT 0,
    total_bells INTEGER DEFAULT 0,
    total_weight NUMERIC(10,2) DEFAULT 0,
    bell_no TEXT,
    party_name TEXT,
    items_count INTEGER DEFAULT 0,
    weight_kg NUMERIC(8,2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.bells ADD COLUMN IF NOT EXISTS item_name TEXT;
ALTER TABLE public.bells ADD COLUMN IF NOT EXISTS bell_weight NUMERIC(8,2) DEFAULT 0;
ALTER TABLE public.bells ADD COLUMN IF NOT EXISTS total_bells INTEGER DEFAULT 0;
ALTER TABLE public.bells ADD COLUMN IF NOT EXISTS total_weight NUMERIC(10,2) DEFAULT 0;

-- 11. Media Registry Table
CREATE TABLE IF NOT EXISTS public.media_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    serial TEXT,
    name TEXT,
    brand TEXT,
    category TEXT,
    top_size_from TEXT,
    top_size_to TEXT,
    btm_size_from TEXT,
    btm_size_to TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================================
-- DISABLE ROW LEVEL SECURITY (RLS) ON ALL TABLES
-- =====================================================================
ALTER TABLE public.rh_users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.employees DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_records DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.ab_grade_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.grading_records DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.grading_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.petty_cash DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_movements DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.bells DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.media_items DISABLE ROW LEVEL SECURITY;

GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;

-- =====================================================================
-- INITIAL SEED DATA
-- =====================================================================

-- Default Staff Login Accounts
INSERT INTO public.rh_users (id, name, username, password, role)
VALUES 
    ('u_admin', 'Master Administrator', 'admin', 'admin123', 'admin'),
    ('u_superuser', 'Executive Super User', 'superuser', 'super123', 'super_user'),
    ('u_grader', 'Zahid Hussain', 'grader_zahid', 'RH-Grad782', 'grader'),
    ('u_checker', 'Farhan Ali', 'checker_farhan', 'RH-Check319', 'checker'),
    ('u_helper', 'Bilal Khan', 'helper_bilal', 'RH-Help904', 'floor_helper'),
    ('u_special', 'Special Executive', 'special', 'salaampm', 'super_user')
ON CONFLICT (username) DO NOTHING;

-- Default Employees
INSERT INTO public.employees (id, name, role, designation, phone, salary, username, status)
VALUES
    ('emp_1', 'Master Administrator', 'admin', 'System Administrator', '+92 300 1112233', 150000, 'admin', 'Active'),
    ('emp_2', 'Executive Super User', 'super_user', 'Operations Director', '+92 300 2223344', 120000, 'superuser', 'Active'),
    ('emp_3', 'Zahid Hussain', 'grader', 'Lead Garment Grader', '+92 312 3456789', 55000, 'grader_zahid', 'Active'),
    ('emp_4', 'Farhan Ali', 'checker', 'Senior Quality Inspector', '+92 321 9876543', 60000, 'checker_farhan', 'Active'),
    ('emp_5', 'Bilal Khan', 'floor_helper', 'Warehouse Floor Assistant', '+92 333 4567890', 40000, 'helper_bilal', 'Active'),
    ('emp_6', 'Kamran Akram', 'grader', 'Bale Sorter & Grader', '+92 345 5678901', 52000, 'grader_kamran', 'Active'),
    ('emp_7', 'Sajid Mehmood', 'floor_helper', 'Stock Loading Assistant', '+92 311 6789012', 38000, 'helper_sajid', 'Active')
ON CONFLICT (id) DO NOTHING;

-- Default Grading Categories
INSERT INTO public.grading_categories (name, color)
VALUES
    ('A Grade Stock', 'green'),
    ('AB Grade Stock', 'blue'),
    ('Wash / Cleaning', 'amber'),
    ('Repairing & Zippers', 'purple'),
    ('Order Ready Stock', 'burgundy'),
    ('Heavy Defect / Scrap', 'red')
ON CONFLICT (name) DO NOTHING;

-- Initial AB Grade Items
INSERT INTO public.ab_grade_items (id, name, location, category, pcs)
VALUES
    ('a0000000-0000-0000-0000-000000000001', 'Ralph Lauren Oxford Shirts', 'Rack A-01', 'Shirts', 145),
    ('a0000000-0000-0000-0000-000000000002', 'Vintage Carhartt Jackets', 'Rack A-02', 'Workwear', 52),
    ('a0000000-0000-0000-0000-000000000003', 'Levi''s 501 Denim Mix', 'Shelf B-04', 'Denim', 180),
    ('a0000000-0000-0000-0000-000000000004', 'Patagonia & TNF Fleeces', 'Rack C-01', 'Fleeces', 95),
    ('a0000000-0000-0000-0000-000000000005', 'Nike / Adidas Vintage Hoodies', 'Shelf D-02', 'Sportswear', 115)
ON CONFLICT (id) DO NOTHING;

-- Initial Customer Ready Stock
INSERT INTO public.customer_items (id, customer_name, name, category, qty, rack, status, notes)
VALUES
    ('c0000000-0000-0000-0000-000000000001', 'Vintage Hub London', 'Heavy Carhartt Canvas Jackets', 'Workwear', 50, 'Shelf C-1', 'Ready', 'Packed in Box 1 & 2'),
    ('c0000000-0000-0000-0000-000000000002', 'Vintage Hub London', 'Patagonia Synchilla Fleeces', 'Fleeces', 35, 'Shelf C-2', 'Ready', 'Ready for export air freight'),
    ('c0000000-0000-0000-0000-000000000003', 'Manchester Retro Vault', 'Levi''s 505 Grade A Denim', 'Denim', 80, 'Box #14', 'In Progress', 'Final checking done'),
    ('c0000000-0000-0000-0000-000000000004', 'Tokyo Vintage Collective', 'Ralph Lauren Big Shirt Corduroy', 'Shirts', 40, 'Rack T-08', 'Ready', 'Customs tag affixed')
ON CONFLICT (id) DO NOTHING;
-- ═══════════════════════════════════════════════════════════════════
-- RAGS HEAVEN — Suppliers & Buyers Accounting Module Schema
-- Supabase / PostgreSQL
-- ═══════════════════════════════════════════════════════════════════

-- ─── 1. SUPPLIERS ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.suppliers (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name             TEXT NOT NULL,
    company          TEXT,
    phone            TEXT,
    email            TEXT,
    address          TEXT,
    city             TEXT,
    currency         TEXT DEFAULT 'PKR',
    opening_balance  NUMERIC(14,2) DEFAULT 0,
    status           TEXT DEFAULT 'Active',
    notes            TEXT,
    created_at       TIMESTAMPTZ DEFAULT NOW(),
    updated_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ─── 2. SUPPLIER TRANSACTIONS ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.supplier_transactions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_id     UUID NOT NULL REFERENCES public.suppliers(id) ON DELETE CASCADE,
    type            TEXT NOT NULL CHECK (type IN ('purchase', 'return', 'adjustment')),
    invoice_no      TEXT NOT NULL,
    date            DATE NOT NULL DEFAULT CURRENT_DATE,
    items           JSONB DEFAULT '[]',
    subtotal        NUMERIC(14,2) DEFAULT 0,
    transport       NUMERIC(14,2) DEFAULT 0,
    loading         NUMERIC(14,2) DEFAULT 0,
    tax             NUMERIC(14,2) DEFAULT 0,
    discount        NUMERIC(14,2) DEFAULT 0,
    custom_charges  JSONB DEFAULT '[]',
    grand_total     NUMERIC(14,2) DEFAULT 0,
    notes           TEXT,
    created_by      TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ─── 3. SUPPLIER PAYMENTS ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.supplier_payments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_id     UUID NOT NULL REFERENCES public.suppliers(id) ON DELETE CASCADE,
    transaction_id  UUID,
    receipt_no      TEXT NOT NULL,
    date            DATE NOT NULL DEFAULT CURRENT_DATE,
    amount          NUMERIC(14,2) NOT NULL,
    payment_method  TEXT DEFAULT 'Cash',
    bank_ref        TEXT,
    type            TEXT DEFAULT 'payment' CHECK (type IN ('payment', 'advance', 'reversal')),
    notes           TEXT,
    created_by      TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ─── 4. BUYERS ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.buyers (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name             TEXT NOT NULL,
    company          TEXT,
    contact_person   TEXT,
    phone            TEXT,
    email            TEXT,
    address          TEXT,
    city             TEXT,
    country          TEXT,
    currency         TEXT DEFAULT 'PKR',
    opening_balance  NUMERIC(14,2) DEFAULT 0,
    status           TEXT DEFAULT 'Active',
    notes            TEXT,
    created_at       TIMESTAMPTZ DEFAULT NOW(),
    updated_at       TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.buyers ADD COLUMN IF NOT EXISTS company TEXT;
ALTER TABLE public.buyers ADD COLUMN IF NOT EXISTS contact_person TEXT;
ALTER TABLE public.buyers ADD COLUMN IF NOT EXISTS country TEXT;
ALTER TABLE public.buyers ADD COLUMN IF NOT EXISTS opening_balance NUMERIC(14,2) DEFAULT 0;

-- ─── 5. BUYER TRANSACTIONS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.buyer_transactions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id        UUID NOT NULL REFERENCES public.buyers(id) ON DELETE CASCADE,
    type            TEXT NOT NULL CHECK (type IN ('purchase', 'return', 'adjustment')),
    invoice_no      TEXT NOT NULL,
    date            DATE NOT NULL DEFAULT CURRENT_DATE,
    items           JSONB DEFAULT '[]',
    subtotal        NUMERIC(14,2) DEFAULT 0,
    transport       NUMERIC(14,2) DEFAULT 0,
    loading         NUMERIC(14,2) DEFAULT 0,
    tax             NUMERIC(14,2) DEFAULT 0,
    discount        NUMERIC(14,2) DEFAULT 0,
    custom_charges  JSONB DEFAULT '[]',
    grand_total     NUMERIC(14,2) DEFAULT 0,
    notes           TEXT,
    created_by      TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ─── 6. BUYER PAYMENTS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.buyer_payments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id        UUID NOT NULL REFERENCES public.buyers(id) ON DELETE CASCADE,
    transaction_id  UUID,
    receipt_no      TEXT NOT NULL,
    date            DATE NOT NULL DEFAULT CURRENT_DATE,
    amount          NUMERIC(14,2) NOT NULL,
    payment_method  TEXT DEFAULT 'Cash',
    bank_ref        TEXT,
    type            TEXT DEFAULT 'receipt' CHECK (type IN ('receipt', 'advance', 'reversal')),
    notes           TEXT,
    created_by      TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════════
-- DISABLE ROW LEVEL SECURITY
-- ═══════════════════════════════════════════════════════════════════
ALTER TABLE public.suppliers            DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.supplier_transactions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.supplier_payments    DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.buyers               DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.buyer_transactions   DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.buyer_payments       DISABLE ROW LEVEL SECURITY;

-- ═══════════════════════════════════════════════════════════════════
-- GRANT PERMISSIONS
-- ═══════════════════════════════════════════════════════════════════
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
