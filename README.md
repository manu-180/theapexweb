# Desde la raíz del proyecto APEX
Remove-Item -Recurse -Force docs
flutter build web --dart-define=SUPABASE_URL=https://osoijzjxzxdkwmobctyb.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9zb2lqemp4enhka3dtb2JjdHliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0NzMxNTAsImV4cCI6MjA3ODA0OTE1MH0.tsxK2R7DMHGxpL4zvjnBVd71Mwa5nDrNkA7DtGt7MIw
mkdir docs
Copy-Item -Recurse -Force build\web\* docs\
git add .
git commit -m "vercel"
git push

seleccionar el icono :
""
dart run flutter_launcher_icons 
""
