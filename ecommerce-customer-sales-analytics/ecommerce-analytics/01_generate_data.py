import numpy as np
import pandas as pd
import random
from datetime import date, timedelta
import os

random.seed(42)
np.random.seed(42)

BASE = "/home/claude/ecommerce-analytics"
for d in ["data", "sql", "analysis/charts", "dashboard", "excel"]:
    os.makedirs(f"{BASE}/{d}", exist_ok=True)

START_DATE = date(2023, 1, 1)
END_DATE = date(2026, 8, 31)
TOTAL_DAYS = (END_DATE - START_DATE).days

# ---------------------------------------------------------------- lookups --
FIRST_NAMES = ["James","Mary","Robert","Patricia","John","Jennifer","Michael","Linda","David","Elizabeth",
"William","Barbara","Richard","Susan","Joseph","Jessica","Thomas","Sarah","Charles","Karen",
"Christopher","Nancy","Daniel","Lisa","Matthew","Betty","Anthony","Margaret","Mark","Sandra",
"Priya","Arjun","Ananya","Rohan","Kavita","Vikram","Neha","Rajesh","Sunita","Amit",
"Wei","Mei","Jin","Yuki","Hiroshi","Carlos","Maria","Jose","Ana","Luis",
"Fatima","Ahmed","Sofia","Omar","Elena","Chen","Olivia","Liam","Emma","Noah",
"Aiden","Sophia","Lucas","Isabella","Ethan","Mia","Mason","Amelia","Logan","Harper"]

LAST_NAMES = ["Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez","Martinez",
"Hernandez","Lopez","Gonzalez","Wilson","Anderson","Thomas","Taylor","Moore","Jackson","Martin",
"Sharma","Patel","Gupta","Kumar","Singh","Reddy","Nair","Iyer","Rao","Mehta",
"Chen","Wang","Li","Zhang","Liu","Yamamoto","Tanaka","Kim","Park","Nguyen",
"Kelly","Wright","Scott","Torres","Diaz","Hill","Flores","Green","Adams","Baker"]

CITIES = [
    ("New York","NY","USA","Northeast"),("Los Angeles","CA","USA","West"),("Chicago","IL","USA","Midwest"),
    ("Houston","TX","USA","South"),("Phoenix","AZ","USA","West"),("Philadelphia","PA","USA","Northeast"),
    ("San Antonio","TX","USA","South"),("San Diego","CA","USA","West"),("Dallas","TX","USA","South"),
    ("Austin","TX","USA","South"),("San Jose","CA","USA","West"),("Columbus","OH","USA","Midwest"),
    ("Charlotte","NC","USA","South"),("Indianapolis","IN","USA","Midwest"),("Seattle","WA","USA","West"),
    ("Denver","CO","USA","West"),("Boston","MA","USA","Northeast"),("Nashville","TN","USA","South"),
    ("Detroit","MI","USA","Midwest"),("Portland","OR","USA","West"),("Atlanta","GA","USA","South"),
    ("Miami","FL","USA","South"),("Minneapolis","MN","USA","Midwest"),("Cleveland","OH","USA","Midwest"),
    ("Tampa","FL","USA","South"),("Orlando","FL","USA","South"),("St. Louis","MO","USA","Midwest"),
    ("Pittsburgh","PA","USA","Northeast"),("Sacramento","CA","USA","West"),("Kansas City","MO","USA","Midwest"),
    ("Las Vegas","NV","USA","West"),("Baltimore","MD","USA","Northeast"),("Milwaukee","WI","USA","Midwest"),
    ("Raleigh","NC","USA","South"),("Salt Lake City","UT","USA","West"),
    ("Toronto","ON","Canada","International"),("Vancouver","BC","Canada","International"),
    ("London","","UK","International"),("Manchester","","UK","International"),
    ("Sydney","NSW","Australia","International"),("Melbourne","VIC","Australia","International"),
]

CATEGORIES = {
    "Electronics":            {"cogs": 0.62, "ret": 0.9, "price": (15, 600)},
    "Apparel & Clothing":     {"cogs": 0.42, "ret": 2.2, "price": (12, 130)},
    "Footwear":               {"cogs": 0.45, "ret": 2.0, "price": (25, 190)},
    "Home & Kitchen":         {"cogs": 0.52, "ret": 0.8, "price": (10, 260)},
    "Beauty & Personal Care": {"cogs": 0.38, "ret": 0.5, "price": (6, 95)},
    "Sports & Outdoors":      {"cogs": 0.50, "ret": 0.9, "price": (10, 320)},
    "Books & Media":          {"cogs": 0.55, "ret": 0.3, "price": (8, 45)},
    "Toys & Games":           {"cogs": 0.48, "ret": 0.7, "price": (8, 95)},
    "Grocery & Gourmet":      {"cogs": 0.60, "ret": 0.2, "price": (4, 65)},
    "Furniture":              {"cogs": 0.55, "ret": 1.4, "price": (40, 950)},
}
CAT_LIST = list(CATEGORIES.keys())

PRODUCT_BASE = {
    "Electronics": ["Wireless Earbuds","Bluetooth Speaker","Smart Watch","Action Camera","Noise-Cancelling Headphones",
                    "Portable Charger","Smart Home Hub","Gaming Mouse","Mechanical Keyboard","Tablet Stand",
                    "HD Webcam","Fitness Tracker","Wireless Charging Pad","Laptop Stand","USB-C Hub"],
    "Apparel & Clothing": ["Cotton T-Shirt","Slim-Fit Jeans","Wool Sweater","Rain Jacket","Yoga Leggings",
                    "Flannel Shirt","Summer Dress","Denim Jacket","Hoodie","Chino Shorts","Linen Shirt","Puffer Vest"],
    "Footwear": ["Running Shoes","Leather Boots","Canvas Sneakers","Hiking Boots","Sandals",
                    "Dress Shoes","Trail Runners","Slip-On Loafers"],
    "Home & Kitchen": ["Stainless Steel Water Bottle","Non-Stick Frying Pan","Ceramic Mug Set","Knife Block Set",
                    "Air Fryer","Blender","Bedsheet Set","Throw Pillow","Vacuum Cleaner","Coffee Maker",
                    "Cutting Board","Storage Bin Set"],
    "Beauty & Personal Care": ["Facial Cleanser","Moisturizing Cream","Shampoo & Conditioner Set","Electric Toothbrush",
                    "Hair Dryer","Perfume","Lip Balm Set","Sunscreen SPF50"],
    "Sports & Outdoors": ["Yoga Mat","Adjustable Dumbbell Set","Camping Tent","Insulated Water Bottle","Bicycle Helmet",
                    "Resistance Bands","Hiking Backpack","Sleeping Bag"],
    "Books & Media": ["Bestselling Novel","Cookbook","Self-Help Book","Children's Picture Book","Puzzle Book",
                    "Graphic Novel","Biography"],
    "Toys & Games": ["Building Block Set","Board Game","1000-Piece Puzzle","Remote Control Car","Plush Toy",
                    "Card Game","Action Figure"],
    "Grocery & Gourmet": ["Organic Coffee Beans","Assorted Nuts Pack","Extra Virgin Olive Oil","Herbal Tea Set",
                    "Dark Chocolate Bar Pack","Protein Powder","Granola Pack"],
    "Furniture": ["Office Chair","Standing Desk","Bookshelf","Sofa","Bar Stool Set","Bed Frame","TV Stand","Accent Table"],
}
VARIANTS = ["", " Pro", " Mini", " Max", " Lite", " 2.0", " Plus", " Classic", " Deluxe"]

def make_products():
    rows, pid = [], 1
    target_counts = {"Electronics": 42, "Apparel & Clothing": 46, "Footwear": 26, "Home & Kitchen": 36,
        "Beauty & Personal Care": 28, "Sports & Outdoors": 28, "Books & Media": 22,
        "Toys & Games": 24, "Grocery & Gourmet": 22, "Furniture": 20}
    for cat, n in target_counts.items():
        combos = [(b, v) for b in PRODUCT_BASE[cat] for v in VARIANTS]
        random.shuffle(combos)
        lo, hi = CATEGORIES[cat]["price"]
        for b, v in combos[:n]:
            name = f"{b}{v}".strip()
            price = round(random.uniform(lo, hi), 2)
            cost = round(price * CATEGORIES[cat]["cogs"] * random.uniform(0.9, 1.1), 2)
            rows.append((pid, name, cat, price, cost))
            pid += 1
    return pd.DataFrame(rows, columns=["product_id","product_name","category","list_price","unit_cost"])

products_df = make_products()

# --------------------------------------------------------------- customers --
CHANNELS = ["Organic Search","Paid Social","Direct","Email Marketing","Referral"]
CHANNEL_WEIGHTS = [0.34, 0.24, 0.20, 0.13, 0.09]

SEGMENT_BASE = {"champion":0.12, "loyal":0.28, "occasional":0.35, "one_time":0.25}
SEGMENT_PARAMS = {
    "champion":  {"orders": (15,35), "gap_mean": 24},
    "loyal":     {"orders": (6,14),  "gap_mean": 42},
    "occasional":{"orders": (2,5),   "gap_mean": 78},
    "one_time":  {"orders": (1,1),   "gap_mean": None},
}
CHANNEL_SEG_MULT = {
    "Organic Search": {"champion":1.3,"loyal":1.15,"occasional":0.9,"one_time":0.8},
    "Referral":       {"champion":1.6,"loyal":1.3,"occasional":0.8,"one_time":0.55},
    "Direct":         {"champion":1.1,"loyal":1.1,"occasional":1.0,"one_time":0.9},
    "Email Marketing":{"champion":1.0,"loyal":1.05,"occasional":1.0,"one_time":1.0},
    "Paid Social":    {"champion":0.55,"loyal":0.7,"occasional":1.15,"one_time":1.6},
}

def picksegment(channel):
    mult = CHANNEL_SEG_MULT[channel]
    weights = {k: SEGMENT_BASE[k]*mult[k] for k in SEGMENT_BASE}
    total = sum(weights.values())
    r = random.random()*total
    cum = 0
    for k,w in weights.items():
        cum += w
        if r <= cum:
            return k
    return "occasional"

N_CUSTOMERS = 5000
customers = []
for cid in range(1, N_CUSTOMERS+1):
    fn = random.choice(FIRST_NAMES); ln = random.choice(LAST_NAMES)
    city, state, country, region = random.choice(CITIES)
    channel = random.choices(CHANNELS, weights=CHANNEL_WEIGHTS)[0]
    acq_date = START_DATE + timedelta(days=random.randint(0, TOTAL_DAYS-1))
    email = f"{fn.lower()}.{ln.lower()}{cid}@example.com"
    segment = picksegment(channel)
    customers.append([cid, fn, ln, email, city, state, country, region, channel, acq_date, segment])

customers_df = pd.DataFrame(customers, columns=["customer_id","first_name","last_name","email","city","state",
                                                 "country","region","acquisition_channel","first_order_date","segment"])

customer_affinity = {cid: random.sample(CAT_LIST, random.choice([1,1,2])) for cid in customers_df["customer_id"]}

# ------------------------------------------------------------------ orders --
orders_rows, order_id = [], 1
for row in customers_df.itertuples():
    seg = row.segment
    lo, hi = SEGMENT_PARAMS[seg]["orders"]
    n_orders = random.randint(lo, hi)
    gap_mean = SEGMENT_PARAMS[seg]["gap_mean"]
    cur_date = row.first_order_date
    dates = [cur_date]
    for i in range(1, n_orders):
        gap = np.random.exponential(gap_mean) if gap_mean else 0
        cur_date = cur_date + timedelta(days=max(3,int(round(gap))))
        if cur_date > END_DATE:
            break
        dates.append(cur_date)
    if random.random() < 0.30:
        span_start = dates[0]
        y = random.choice(range(span_start.year, END_DATE.year+1))
        month = random.choice([11,12])
        day = random.randint(1, 24 if month==11 else 20)
        hd = date(y, month, day)
        if span_start <= hd <= END_DATE:
            dates.append(hd)
    for d in sorted(set(dates)):
        orders_rows.append([order_id, row.customer_id, d])
        order_id += 1

orders_df = pd.DataFrame(orders_rows, columns=["order_id","customer_id","order_date"])
orders_df = orders_df.merge(customers_df[["customer_id","acquisition_channel"]], on="customer_id")

def gen_discount(channel):
    r = random.random()
    t = (0.35,0.60,0.85) if channel == "Email Marketing" else (0.45,0.70,0.90)
    if r < t[0]: return 0.0
    elif r < t[1]: return round(random.uniform(0.01,0.10),2)
    elif r < t[2]: return round(random.uniform(0.11,0.25),2)
    else: return round(random.uniform(0.26,0.40),2)

orders_df["discount_pct"] = orders_df["acquisition_channel"].apply(gen_discount)

def gen_promised(method):
    return {"Standard": random.randint(5,7), "Express": random.randint(2,3), "Same-Day": 1}[method]

def gen_actual(promised, method):
    delay_prob = {"Standard":0.08,"Express":0.05,"Same-Day":0.03}[method]
    if random.random() < delay_prob:
        return promised + random.randint(3,10)
    return max(0, promised + random.randint(-1,1))

orders_df["shipping_method"] = random.choices(["Standard","Express","Same-Day"], weights=[0.65,0.25,0.10], k=len(orders_df))
orders_df["promised_delivery_days"] = orders_df["shipping_method"].apply(gen_promised)
orders_df["actual_delivery_days"] = [gen_actual(p,m) for p,m in zip(orders_df.promised_delivery_days, orders_df.shipping_method)]
orders_df["delivery_date"] = [d + timedelta(days=int(a)) for d,a in zip(orders_df.order_date, orders_df.actual_delivery_days)]

# ------------------------------------------------------------- order items --
products_by_cat = {cat: products_df[products_df.category==cat].reset_index(drop=True) for cat in CAT_LIST}
order_items_rows, oi_id = [], 1
for row in orders_df.itertuples():
    n_items = random.choices([1,2,3,4], weights=[0.45,0.32,0.16,0.07])[0]
    affinity = customer_affinity[row.customer_id]
    for _ in range(n_items):
        cat = random.choice(affinity) if random.random() < 0.7 else random.choice(CAT_LIST)
        prod = products_by_cat[cat].sample(1).iloc[0]
        qty = random.choices([1,2,3], weights=[0.75,0.18,0.07])[0]
        order_items_rows.append([oi_id, row.order_id, prod.product_id, qty, prod.list_price])
        oi_id += 1

order_items_df = pd.DataFrame(order_items_rows, columns=["order_item_id","order_id","product_id","quantity","unit_price"])
order_items_df["line_subtotal"] = order_items_df.quantity * order_items_df.unit_price
order_items_df = order_items_df.merge(orders_df[["order_id","discount_pct"]], on="order_id")
order_items_df["line_discount_amount"] = (order_items_df.line_subtotal * order_items_df.discount_pct).round(2)
order_items_df["line_net_revenue"] = (order_items_df.line_subtotal - order_items_df.line_discount_amount).round(2)
order_items_df = order_items_df.merge(products_df[["product_id","unit_cost","category"]], on="product_id")
order_items_df["line_cost"] = (order_items_df.quantity * order_items_df.unit_cost).round(2)
order_items_df["line_profit"] = (order_items_df.line_net_revenue - order_items_df.line_cost).round(2)

# shipping cost depends on order subtotal (free standard shipping over $75)
order_subtotal = order_items_df.groupby("order_id")["line_subtotal"].sum().rename("order_subtotal")
orders_df = orders_df.merge(order_subtotal, on="order_id", how="left")
def ship_cost(method, subtotal):
    if method=="Standard": return 0.0 if subtotal>=75 else 4.99
    if method=="Express": return 12.99
    return 19.99
orders_df["shipping_cost"] = [ship_cost(m,s) for m,s in zip(orders_df.shipping_method, orders_df.order_subtotal)]

# --------------------------------------------------------------- returns ----
oi_temp = order_items_df.merge(orders_df[["order_id","promised_delivery_days","actual_delivery_days","delivery_date"]], on="order_id")
RETURN_REASONS_GENERAL = ["Changed mind","Not as described","Defective/damaged"]
RETURN_REASONS_FIT = ["Wrong size/fit","Changed mind","Not as described"]
returns_rows, rid = [], 1
for row in oi_temp.itertuples():
    cat_mult = CATEGORIES[row.category]["ret"]
    late = (row.actual_delivery_days - row.promised_delivery_days) > 3
    p = min(0.55, 0.05 * cat_mult * (1.3 if late else 1.0))
    if random.random() < p:
        ret_date = row.delivery_date + timedelta(days=random.randint(2,15))
        if row.category in ["Apparel & Clothing","Footwear"]:
            reason = random.choices(RETURN_REASONS_FIT, weights=[0.55,0.25,0.20])[0]
        else:
            reason = random.choices(RETURN_REASONS_GENERAL, weights=[0.4,0.3,0.3])[0]
        returns_rows.append([rid, row.order_item_id, ret_date, reason, row.line_net_revenue])
        rid += 1
returns_df = pd.DataFrame(returns_rows, columns=["return_id","order_item_id","return_date","return_reason","refund_amount"])

# ---------------------------------------------------------- marketing spend --
months = pd.date_range(START_DATE, END_DATE, freq="MS").date
BASE_SPEND = {"Paid Social": 8000, "Organic Search": 1500, "Email Marketing": 900, "Referral": 500}
spend_rows = []
for m in months:
    holiday_mult = 1.6 if m.month in (11,12) else 1.0
    for ch, base in BASE_SPEND.items():
        spend_rows.append([ch, m, round(base*holiday_mult*random.uniform(0.85,1.15),2)])
marketing_spend_df = pd.DataFrame(spend_rows, columns=["channel","month","spend"])

# -------------------------------------------------------------------- save --
customers_out = customers_df.drop(columns=["segment"]).copy()
customers_out["first_order_date"] = customers_out["first_order_date"].astype(str)
customers_out.to_csv(f"{BASE}/data/customers.csv", index=False)

products_df.to_csv(f"{BASE}/data/products.csv", index=False)

orders_out = orders_df[["order_id","customer_id","order_date","shipping_method","shipping_cost",
                         "promised_delivery_days","actual_delivery_days","delivery_date","discount_pct"]].copy()
orders_out["order_date"] = orders_out["order_date"].astype(str)
orders_out["delivery_date"] = orders_out["delivery_date"].astype(str)
orders_out.to_csv(f"{BASE}/data/orders.csv", index=False)

order_items_out = order_items_df[["order_item_id","order_id","product_id","quantity","unit_price","line_subtotal",
     "line_discount_amount","line_net_revenue","line_cost","line_profit"]].copy()
order_items_out.to_csv(f"{BASE}/data/order_items.csv", index=False)

returns_out = returns_df.copy()
returns_out["return_date"] = returns_out["return_date"].astype(str)
returns_out.to_csv(f"{BASE}/data/returns.csv", index=False)

marketing_spend_df["month"] = marketing_spend_df["month"].astype(str)
marketing_spend_df.to_csv(f"{BASE}/data/marketing_spend.csv", index=False)

print("=== Row counts ===")
for f in ["customers","products","orders","order_items","returns","marketing_spend"]:
    df = pd.read_csv(f"{BASE}/data/{f}.csv")
    print(f"{f:16s}", df.shape)

print("\n=== Quick sanity ===")
print("Total net revenue: $%.2f" % order_items_out.line_net_revenue.sum())
print("Overall return rate: %.2f%%" % (100*len(returns_out)/len(order_items_out)))
print("Date range:", orders_out.order_date.min(), "to", orders_out.order_date.max())
print("Segment mix:\n", customers_df["segment"].value_counts(normalize=True).round(3))
