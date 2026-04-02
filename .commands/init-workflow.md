# /init-workflow

Sets up the working directory for a new workflow by creating the folder and copying
the appropriate template files.

**Input**: `$ARGUMENTS` — workflow ID (e.g. `WF-001`)
**Output**: `changes/$ARGUMENTS/` folder with the right template(s) ready to fill in

## Process

### Step 1 — Validate the ID

1. Check that `$ARGUMENTS` is provided. If not, stop and respond:
   "Usage: `/init-workflow {WF-ID}` — example: `/init-workflow WF-001`"
2. Check if `changes/$ARGUMENTS/` already exists.
   - If it does, stop and respond:
     "`changes/$ARGUMENTS/` already exists. Use `/capture-requirements $ARGUMENTS` or
     `/enrich-workflow-spec $ARGUMENTS` to continue working on it."

### Step 2 — Choose the flow

Ask the user:

> Which flow applies to this workflow?
>
> **A — Team**: a PO or non-technical person has already written or will write the requirements.
> Copies `templates/requirements.md` → `changes/$ARGUMENTS/requirements.md`
>
> **B — Freelance**: you are talking directly to the client and will capture requirements yourself.
> Copies `templates/client-notes.md` → `changes/$ARGUMENTS/client-notes.md`

### Step 3 — Create and populate the folder

3. Create the directory `changes/$ARGUMENTS/`
4. Based on the chosen flow:

   **Flow A:**
   - Copy `templates/requirements.md` → `changes/$ARGUMENTS/requirements.md`

   **Flow B:**
   - Copy `templates/client-notes.md` → `changes/$ARGUMENTS/client-notes.md`

### Step 4 — Confirm and guide

5. Confirm what was created and tell the user the next step:

   **Flow A:**
   ```
   Done. Folder created: changes/$ARGUMENTS/

   Open changes/$ARGUMENTS/requirements.md and fill in the workflow description.
   When ready, run: /enrich-workflow-spec $ARGUMENTS
   ```

   **Flow B:**
   ```
   Done. Folder created: changes/$ARGUMENTS/

   Open changes/$ARGUMENTS/client-notes.md and paste the raw client input
   (meeting notes, email, WhatsApp messages — anything works).
   When ready, run: /capture-requirements $ARGUMENTS
   ```
