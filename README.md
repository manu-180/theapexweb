# APEX – Portfolio web

## Login con Google (Web)

En web no se usa el archivo `.env`. Para que el botón **Login con Google** funcione tenés que pasar las credenciales de Supabase al **ejecutar** o **compilar**:

**Ejecutar en Chrome (desarrollo):**
```powershell
flutter run -d chrome --dart-define=SUPABASE_URL=https://TU_PROYECTO.supabase.co --dart-define=SUPABASE_ANON_KEY=tu_anon_key
```

Si no pasás esos `--dart-define`, verás en consola *"Advertencia: Faltan credenciales de Supabase"* y al apretar Login con Google aparecerá un aviso en la app indicando que hay que configurar las credenciales.

---

## Build y deploy (Vercel)

Desde la raíz del proyecto APEX:
```powershell
Remove-Item -Recurse -Force docs
flutter build web --dart-define=SUPABASE_URL=https://osoijzjxzxdkwmobctyb.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9zb2lqemp4enhka3dtb2JjdHliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0NzMxNTAsImV4cCI6MjA3ODA0OTE1MH0.tsxK2R7DMHGxpL4zvjnBVd71Mwa5nDrNkA7DtGt7MIw
mkdir docs
Copy-Item -Recurse -Force build\web\* docs\
git add .
git commit -m "vercel"
git push
```

seleccionar el icono :
""
dart run flutter_launcher_icons 
""
