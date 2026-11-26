-- ═══════════════════════════════════════════════════════════════════
-- RAGS HEAVEN — Warehouse Expenses & Employee Loans Schema
-- Supabase / PostgreSQL
-- ═══════════════════════════════════════════════════════════════════

-- ─── 1. WAREHOUSE EXPENSES (Super User Only) ─────────────────────────
CREATE TABLE IF NOT EXISTS public.warehouse_expenses (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_no      TEXT NOT NULL,
    date            DATE NOT NULL DEFAULT CURRENT_DATE,
    category        TEXT NOT NULL DEFAULT 'Miscellaneous',
    title           TEXT NOT NULL,
    amount          NUMERIC(12,2) NOT NULL DEFAULT 0,
    payment_method  TEXT DEFAULT 'Cash',
    paid_by         TEXT,
    ref_no          TEXT,
    notes           TEXT,
    created_by      TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ─── 2. EMPLOYEE LOANS & ADVANCES ────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.employee_loans (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id         TEXT NOT NULL,
    employee_name       TEXT NOT NULL,
    date                DATE NOT NULL DEFAULT CURRENT_DATE,
    type                TEXT NOT NULL DEFAULT 'loan' CHECK (type IN ('loan', 'advance', 'repayment')),
    amount              NUMERIC(12,2) NOT NULL DEFAULT 0,
    monthly_deduction   NUMERIC(12,2) DEFAULT 0,
    notes               TEXT,
    created_by          TEXT,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.warehouse_expenses DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_loans     DISABLE ROW LEVEL SECURITY;

GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
