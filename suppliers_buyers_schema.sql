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
