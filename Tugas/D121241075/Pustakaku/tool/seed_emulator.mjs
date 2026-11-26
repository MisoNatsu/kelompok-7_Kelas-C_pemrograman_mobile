// Mengisi Firebase Emulator dengan akun demo + contoh pengumuman.
// Jalankan setelah emulator aktif:  node tool/seed_emulator.mjs
const PROJECT = "demo-pustakaku";
const AUTH = "http://localhost:9099";
const FS = `http://localhost:8080/v1/projects/${PROJECT}/databases/(default)/documents`;
const OWNER = { Authorization: "Bearer owner", "Content-Type": "application/json" };

const accounts = [
  { email: "admin@pustakaku.id", password: "admin123", displayName: "Admin Pustakaku", role: "admin" },
  { email: "budi@pustakaku.id", password: "budi123", displayName: "Budi Santoso", role: "user" },
];

async function signUp(a) {
  const res = await fetch(`${AUTH}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo-api-key`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: a.email, password: a.password, displayName: a.displayName, returnSecureToken: true }),
  });
  const json = await res.json();
  if (json.error?.message === "EMAIL_EXISTS") {
    const r = await fetch(`${AUTH}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=demo-api-key`, {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: a.email, password: a.password, returnSecureToken: true }),
    });
    return (await r.json()).localId;
  }
  if (!res.ok) throw new Error(JSON.stringify(json));
  return json.localId;
}

async function setDoc(path, fields) {
  const res = await fetch(`${FS}/${path}`, { method: "PATCH", headers: OWNER, body: JSON.stringify({ fields }) });
  if (!res.ok) throw new Error(`${path}: ${await res.text()}`);
}
const str = (v) => ({ stringValue: v });
const now = () => ({ timestampValue: new Date().toISOString() });

for (const a of accounts) {
  const uid = await signUp(a);
  await setDoc(`users/${uid}`, { email: str(a.email), displayName: str(a.displayName), role: str(a.role), createdAt: now() });
  console.log(`✔ ${a.role.padEnd(5)} ${a.email} / ${a.password}`);
}
await setDoc("announcements/selamat-datang", {
  title: str("Selamat datang di Pustakaku 📚"),
  body: str("Ini pengumuman contoh dari admin. Di mode produksi, setiap pengumuman baru dikirim sebagai push notification ke semua pengguna."),
  authorName: str("Admin Pustakaku"),
  createdAt: now(),
});
console.log("✔ pengumuman contoh dibuat");
console.log("\nEmulator UI: http://localhost:4000");
