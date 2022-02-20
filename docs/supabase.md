# Setting up your supabase environment with points

1. Sign up or sign in into supabase and create a new project

2. Disable email confirmations in the auth config settings 
   (Authentication (Sidebar) > Settings > Enable email confirmations) (Might be changed in later release)
   
3. In the extensions tab search for FUZZYSTRMATCH and enable it
   (Database (Sidebar) > (In the second sidebar under "Databases") Extensions > Searchbar)
   
4. Make a new query (SQL (Sidebar) > New query)

5. Copy paste main.sql into it and click on run

6. Make another new query, but copy functions.sql into it and click on run

7. In the root of the cloned project,
replace the SUPABASE_URL and SUPABASE_ANON_KEYS with your own credentials
from the newly configured supabase project (settings > api > anon public/url)
