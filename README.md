# Αυτοψία (PWA)

Εφαρμογή επιθεώρησης αυτοκινήτων: βαφή, διορθώσεις, ελαστικά, ελλείψεις, φωτογραφίες, αναφορά διαπραγμάτευσης.
Δουλεύει χωρίς ίντερνετ και συγχρονίζει με Supabase όταν υπάρχει σήμα.

## Αρχεία
- `index.html`: η εφαρμογή
- `sw.js`: service worker (offline)
- `manifest.webmanifest`, `icons/`: εγκατάσταση στο κινητό
- `config.js`: Supabase URL και anon key (προαιρετικά, μπαίνουν και από τις Ρυθμίσεις)
- `vendor/supabase.js`: supabase-js 2.49.10
- `supabase-setup.sql`: τρέχει μία φορά στο Supabase SQL Editor

## Ενημέρωση
Όταν αλλάζεις κάτι, άλλαξε το `VERSION` στο `sw.js` (π.χ. `autopsia-v2`) για να πάρουν τα κινητά τη νέα έκδοση.
