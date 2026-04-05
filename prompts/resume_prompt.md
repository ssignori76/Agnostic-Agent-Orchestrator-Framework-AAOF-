# AAOF — Istruzioni di Ripresa Sessione

> Questo prompt è destinato a un sub-agente che deve continuare
> un lavoro iniziato da un altro agente o sessione precedente.

---

## Istruzioni generali

1. Leggi `session/session_state.json` — contiene lo step attuale (`VAR_SESSION_STEP`) e tutte le variabili di sessione
2. Leggi `session/requirements_checklist.json` — contiene i requisiti del progetto e il loro stato (pass/pending/fail)
3. Riprendi dal `VAR_SESSION_STEP` corrente — NON ripartire da STEP 0
4. NON rifare il lavoro già completato — i requisiti con status `"pass"` sono già soddisfatti
5. Continua fino a STEP 7 (Consolidation) o fino a esaurimento turni
6. Se raggiungi il turn limit prima di STEP 7, assicurati che `session/session_state.json` sia aggiornato con lo step corrente

> **Nota:** la lettura di `agent.md` è ora condizionale in base allo step corrente.
> Consulta le istruzioni specifiche per step qui sotto per sapere quali sezioni leggere.

---

## Istruzioni specifiche per step

Adatta il tuo comportamento in base al `VAR_SESSION_STEP` letto da `session_state.json`:

### Se `VAR_SESSION_STEP` <= 3 (Setup / Plan / Backup non completati)

1. Leggi `agent.md` come tuo manuale operativo completo
2. Riprendi dallo step indicato in `session_state.json`
3. Completa il setup e procedi con l'implementazione

### Se `VAR_SESSION_STEP` == 4 (Implementation in corso o completata)

1. Leggi `agent.md`, sezione **STEP 4** e **STEP 5**
2. Leggi `session/requirements_checklist.json`
3. Se il contract check (`VAR_CONTRACT_CHECK`) non è ancora `PASS`, completalo
4. Se il contract check è `PASS`, procedi direttamente con **STEP 5** (Validazione)
5. **NON reimplementare codice già scritto**

### Se `VAR_SESSION_STEP` == 5 (Validation)

1. Leggi `agent.md`, sezione **STEP 5** e **STEP 7**
2. Completa la validazione (test, compliance report)
3. Procedi con **STEP 7** (Consolidamento)
4. **NON tornare a step precedenti**

### Se `VAR_SESSION_STEP` >= 6 (Rollback / Consolidation)

1. Leggi `agent.md`, sezione **STEP 7**
2. Completa il consolidamento finale e genera `output/scoring_report.md`
