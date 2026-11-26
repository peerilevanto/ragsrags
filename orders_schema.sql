-- ═══════════════════════════════════════════════════════════════════
-- RAGS HEAVEN — Orders, Fulfillment, Weight & Dispatch Module Schema
-- Supabase / PostgreSQL
-- ═══════════════════════════════════════════════════════════════════

-- ─── 1. ORDERS ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.orders (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_no            TEXT NOT NULL,
    customer_name       TEXT NOT NULL,
    customer_company    TEXT,
    country             TEXT,
    city                TEXT,
    phone               TEXT,
    email               TEXT,
    order_date          DATE NOT NULL DEFAULT CURRENT_DATE,
    target_dispatch_date DATE,
    actual_dispatch_date DATE,
    priority            TEXT DEFAULT 'Normal' CHECK (priority IN ('Normal', 'High', 'Urgent')),
    status              TEXT DEFAULT 'Pending' CHECK (status IN (
                            'Pending', 'In Grading', 'Repair & Wash', 'Checking', 'Packing & Weighing',
                            'Ready to Dispatch', 'Dispatched', 'Delivered', 'Cancelled'
                        )),
    currency            TEXT DEFAULT 'EUR',
    target_weight_kg    NUMERIC(10,2) DEFAULT 0,
    actual_weight_kg    NUMERIC(10,2) DEFAULT 0,
    total_bales         INTEGER DEFAULT 0,
    shipping_method     TEXT DEFAULT 'Sea Freight (Container)',
    shipping_carrier    TEXT,
    container_no        TEXT,
    port_of_destination TEXT,
    notes               TEXT,
    created_by          TEXT,
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ─── 2. ORDER ITEMS ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.order_items (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id            UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    item_name           TEXT NOT NULL,
    category            TEXT DEFAULT 'Grade A',
    size_spec           TEXT,
    req_pcs             INTEGER NOT NULL DEFAULT 0,
    graded_pcs          INTEGER DEFAULT 0,
    repair_pcs          INTEGER DEFAULT 0,
    wash_pcs            INTEGER DEFAULT 0,
    checked_pcs         INTEGER DEFAULT 0,
    packed_pcs          INTEGER DEFAULT 0,
    req_weight_kg       NUMERIC(10,2) DEFAULT 0,
    actual_weight_kg    NUMERIC(10,2) DEFAULT 0,
    bales_count         INTEGER DEFAULT 0,
    unit_price          NUMERIC(12,2) DEFAULT 0,
    assigned_grader     TEXT,
    checker_name        TEXT,
    item_status         TEXT DEFAULT 'Pending' CHECK (item_status IN (
                            'Pending', 'In Progress', 'Graded', 'Checked', 'Packed', 'Shortage'
                        )),
    remarks             TEXT,
    sort_order          INTEGER DEFAULT 0,
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ─── 3. ORDER DISPATCHES ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.order_dispatches (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id            UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    dispatch_no         TEXT NOT NULL,
    dispatch_date       DATE NOT NULL DEFAULT CURRENT_DATE,
    shipping_method     TEXT DEFAULT 'Sea Freight (Container)',
    carrier_name        TEXT,
    tracking_or_bl_no   TEXT,
    seal_no             TEXT,
    bales_count         INTEGER DEFAULT 0,
    net_weight_kg       NUMERIC(10,2) DEFAULT 0,
    gross_weight_kg     NUMERIC(10,2) DEFAULT 0,
    dispatched_items    JSONB DEFAULT '[]'::jsonb,
    status              TEXT DEFAULT 'Preparing' CHECK (status IN (
                            'Preparing', 'Dispatched', 'In Transit', 'Delivered'
                        )),
    notes               TEXT,
    created_by          TEXT,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ─── 4. ORDER TRACKING LOGS ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.order_logs (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id            UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    action              TEXT NOT NULL,
    details             TEXT,
    actor_name          TEXT,
    actor_role          TEXT,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════════
-- DISABLE ROW LEVEL SECURITY & GRANT PERMISSIONS
-- ═══════════════════════════════════════════════════════════════════
ALTER TABLE public.orders           DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items      DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_dispatches DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_logs       DISABLE ROW LEVEL SECURITY;

GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;

-- Safe upgrades if tables already exist
ALTER TABLE public.order_items ADD COLUMN IF NOT EXISTS repair_pcs INTEGER DEFAULT 0;
ALTER TABLE public.order_items ADD COLUMN IF NOT EXISTS wash_pcs INTEGER DEFAULT 0;
ALTER TABLE public.orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE public.orders ADD CONSTRAINT orders_status_check CHECK (status IN (
    'Pending', 'In Grading', 'Repair & Wash', 'Checking', 'Packing & Weighing',
    'Ready to Dispatch', 'Dispatched', 'Delivered', 'Cancelled'
));
