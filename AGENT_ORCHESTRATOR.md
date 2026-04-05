# AAOF — Agent Orchestrator Guide

> Questo file è destinato a un agente AI che orchestra l'esecuzione
> del framework AAOF tramite sub-agenti. Se sei un umano, leggi README.md.

---

## 1. Chi sei

Sei un agente orchestratore. Il tuo compito è:

- Configurare il framework AAOF per il progetto richiesto dall'utente
- Lanciare un sub-agente per implementare il progetto
- Monitorare il completamento
- Rilanciare il sub-agente se raggiunge il turn limit

NON implementi il progetto direttamente. Deleghi a un sub-agente.

---

## 2. Configurazione del progetto

1. Chiedi all'utente cosa vuole realizzare (tipo di progetto, stack tecnologico, funzionalità)
2. Scrivi `config.json` con: `project_name`, `project_description`, `stack`, `deploy_targets`, `environment_context`
3. Crea una spec dettagliata in `specs/active/001-spec.md` con tutti i requisiti funzionali

---

## 3. Primo lancio del sub-agente

Lancia un sub-agente nella directory del progetto con questa istruzione esatta:

```
Leggi agent.md come tuo manuale operativo. Implementa il progetto partendo da STEP 0.
Segui rigorosamente il workflow a 8 step descritto in agent.md. Non saltare alcun passaggio.
```

---

## 4. Monitoraggio e rilancio (Turn Limit Recovery)

Quando il sub-agente termina (per completamento o turn limit):

1. Leggi `session/session_state.json`
2. Controlla il campo `VAR_SESSION_STEP`:
   - Se `VAR_SESSION_STEP` == 7 → il progetto è completato, vai a §5
   - Se `VAR_SESSION_STEP` < 7 → il sub-agente non ha finito, rilancia
3. Per rilanciare, usa un nuovo sub-agente con il prompt ottimizzato descritto in §4.3.

### 4.3 Prompt di rilancio ottimizzato

Quando rilanci un sub-agente, adatta il prompt in base al `VAR_SESSION_STEP` corrente:

**Se `VAR_SESSION_STEP` <= 3** (Setup/Plan/Backup non completati):
```
Leggi agent.md come tuo manuale operativo.
Leggi session/session_state.json per conoscere lo stato corrente.
Riprendi dallo step in cui ti trovi. Completa il setup e procedi con l'implementazione.
```

**Se `VAR_SESSION_STEP` == 4** (Implementation in corso o completata):
```
Leggi agent.md, sezione STEP 4 e STEP 5.
Leggi session/session_state.json e session/requirements_checklist.json.
Se il contract check non è ancora stato eseguito, completalo.
Se il contract check è PASS, procedi direttamente con STEP 5 (Validazione).
NON reimplementare codice già scritto.
```

**Se `VAR_SESSION_STEP` == 5** (Validation):
```
Leggi agent.md, sezione STEP 5 e STEP 7.
Leggi session/session_state.json.
Completa la validazione e procedi con STEP 7 (Consolidamento).
NON tornare a step precedenti.
```

**Se `VAR_SESSION_STEP` >= 6** (Rollback/Consolidation):
```
Leggi agent.md, sezione STEP 7.
Leggi session/session_state.json.
Completa il consolidamento finale.
```

IMPORTANTE: Includi sempre nel prompt lo step corrente specifico letto da `session_state.json`.
Questo evita che il sub-agente sprechi turni rileggendo tutto il contesto dall'inizio.

### 4.4 Limite di sicurezza

Il numero massimo di rilanci dipende dalla complessità del progetto:

- **Progetti semplici** (1–5 requisiti nella spec): max 5 rilanci
- **Progetti medi** (6–15 requisiti): max 8 rilanci
- **Progetti complessi** (16+ requisiti): max 12 rilanci

L'orchestratore determina il limite leggendo il numero di requisiti nella spec
(`specs/active/`) al momento della configurazione iniziale.

Se il limite viene raggiunto senza completare il progetto, segui le istruzioni
al §6 per salvare lo stato e permettere la ripresa.

---

## 5. Completamento

Quando `VAR_SESSION_STEP` == 7:

1. Se esiste `output/scoring_report.md`, presentalo all'utente
2. Riassumi cosa è stato implementato
3. Indica all'utente dove trovare il codice (directory `output/`)

---

## 6. Se TU (orchestratore) stai per esaurire i turni

Se rilevi di avere pochi turni rimasti e il progetto non è completato:

1. Salva un file `.aaof/orchestrator_state.json` con:
   - `"rilanci_effettuati"`: numero di sub-agenti lanciati finora
   - `"ultimo_step"`: ultimo `VAR_SESSION_STEP` letto da `session_state.json`
   - `"limite_rilanci"`: il limite massimo calcolato per questo progetto
   - `"prossima_azione"`: descrizione specifica di cosa deve fare il prossimo sub-agente
2. Informa l'utente con questo messaggio esatto (sostituisci `[X]` con il valore di `ultimo_step`):

```
Ho esaurito i miei turni. Il progetto è allo STEP [X].
Rilanciami con: "Leggi AGENT_ORCHESTRATOR.md e .aaof/orchestrator_state.json e continua il lavoro"
```

Quando vieni rilanciato con `orchestrator_state.json`:

1. Leggi `orchestrator_state.json` per recuperare lo stato
2. Leggi `session/session_state.json` per confermare lo step corrente
3. Riprendi il loop di monitoraggio e rilancio da dove ti eri fermato
4. Il contatore dei rilanci riparte da `orchestrator_state.json.rilanci_effettuati`
5. Il limite rilanci è in `orchestrator_state.json.limite_rilanci`
