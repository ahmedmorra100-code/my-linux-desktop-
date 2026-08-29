import sys, subprocess, asyncio, random, string
from playwright.async_api import async_playwright

# 🔗 روابطك الخاصة
TARGET_URLS = [
    "http://p.npcad.com/go/502472/757313",
    "http://p.npcad.com/go/502472/754797",
    "http://p.npcad.com/go/502472/756806",
    "http://p.npcad.com/go/502472/757312",
    "http://p.npcad.com/go/502472/757311"
]

# 🔌 البروكسي
PROXIES = [
    "http://user-nXX73EufQelU-network-eco-country-us:xx7FU5wMfOkS@proxy.proxiware.com:1337"
]

# 💻 قائمة بصمات Windows (10 & 11) Chrome فقط
WIN_CHROME_UAS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
]

# ⚙️ الإعدادات
TOTAL_BATCHES = 100        # عدد الدفعات الإجمالي
BATCH_SIZE = 10            # عدد الجلسات المتزامنة
DYNAMIC_EXIT = True        # مفعل: إنهاء فور تسجيل الظهور
MIN_WAIT = 4               # الحد الأدنى للبقاء
MAX_WAIT = 5               # الحد الأقصى للبقاء
SESSION_TIMEOUT = 25       # مهلة قتل الجلسة المعلقة بالثواني

success_count = 0
fail_count = 0
counter_lock = asyncio.Lock()

# الكلمات الدلالية لحظر التحليل والتتبع الآمنة
TRACKER_KEYWORDS = ["gtag", "ga.js", "analytics.js", "telemetry", "hotjar", "clarity.ms"]

async def optimize_resources(route):
    try:
        req = route.request
        if req.resource_type in ["image", "media", "font", "stylesheet", "ping", "eventsource"]:
            return await route.abort()
        
        url_lower = req.url.lower()
        if any(kw in url_lower for kw in TRACKER_KEYWORDS):
            return await route.abort()
            
        await route.continue_()
    except Exception:
        try: await route.abort()
        except Exception: pass

async def run_session(browser, session_id, url, proxy):
    global success_count, fail_count
    context = None
    try:
        proto, rest = proxy.split("://", 1)
        creds, endpoint = rest.split("@", 1)
        salt = ''.join(random.choices(string.ascii_lowercase + string.digits, k=6))
        
        if ":" in creds:
            u, pw = creds.split(":", 1)
            new_user = f"{u}-session-{salt}"
        else:
            new_user = creds
            pw = ""

        proxy_config = {
            "server": f"{proto}://{endpoint}",
            "username": new_user,
            "password": pw
        }

        user_agent = random.choice(WIN_CHROME_UAS)

        context = await browser.new_context(
            user_agent=user_agent,
            proxy=proxy_config,
            locale="en-US",
            viewport={"width": 1366, "height": 768}
        )
        
        await context.add_init_script("Object.defineProperty(navigator, 'webdriver', { get: () => undefined });")

        page = await context.new_page()
        await page.route("**/*", optimize_resources)
        
        await page.goto(url, wait_until="commit", timeout=SESSION_TIMEOUT * 1000)
        
        if not DYNAMIC_EXIT:
            await asyncio.sleep(random.uniform(MIN_WAIT, MAX_WAIT))
        else:
            await asyncio.sleep(0.5)

        async with counter_lock:
            success_count += 1
            print(f"✅ [جلسة {session_id}] نجحت | الناجح: {success_count} | الفاشل: {fail_count}")
        return True

    except Exception:
        async with counter_lock:
            fail_count += 1
            print(f"❌ [جلسة {session_id}] فشلت | الناجح: {success_count} | الفاشل: {fail_count}")
        return False
    finally:
        if context:
            try: await context.close()
            except Exception: pass

async def main():
    global success_count, fail_count
    total_expected = TOTAL_BATCHES * BATCH_SIZE
    print(f"\n🚀 بدء التشغيل المباشر | الدفعات: {TOTAL_BATCHES} | الجلسات بالدفعة: {BATCH_SIZE}")
    print(f"🎯 إجمالي الجلسات المطلوبة: {total_expected}\n" + "="*55)

    session_id = 0
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        for batch in range(TOTAL_BATCHES):
            tasks = []
            for _ in range(BATCH_SIZE):
                session_id += 1
                url = random.choice(TARGET_URLS)
                proxy = random.choice(PROXIES)
                tasks.append(asyncio.wait_for(run_session(browser, session_id, url, proxy), timeout=SESSION_TIMEOUT))
            
            await asyncio.gather(*tasks, return_exceptions=True)
            print(f"--- 📦 اكتملت الدفعة {batch + 1}/{TOTAL_BATCHES} ---")
            await asyncio.sleep(1)

        await browser.close()
    
    print("\n" + "="*55)
    print(f"🏁 انتهى العمل بالكامل | الإجمالي الناجح: {success_count} | الإجمالي الفاشل: {fail_count}")

if __name__ == "__main__":
    asyncio.run(main())
