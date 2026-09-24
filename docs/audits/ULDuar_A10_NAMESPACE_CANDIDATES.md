# ULDuar A.10 namespace candidate — design only

SOURCE_ONLY. NAMESPACE_CANDIDATE_ONLY. No allocation or reservation ledger has been written.

## Allocation authority

Recommend MODEL B: CANONICAL_RELEASE_MANIFEST. The canonical release selects exact client, server-source/data,
modules, update inputs, supported historical releases and a versioned allocation ledger. Collision review belongs
to this closed definition, rather than to whichever mutable database happens to be installed on a developer machine.

This explicitly refines A.7's requirement for an effective-world export before any allocation. A.7 remains unchanged
as a historical report. A.10 does not waive collision checking: an export is required before adopting an existing
unknown world into the canonical release, or the environment must be independently reconstructed and verified against
the canonical inputs in a later authorized deployment phase. Neither alternative was executed here.

| Model | Strength | Limitation / decision |
| --- | --- | --- |
| A: installed world required before allocation | Can include actual local custom rows, if a complete trustworthy snapshot exists | Couples allocation to one mutable installation; an export alone does not cover other releases or clients |
| B: canonical release manifest | Reproducible source/package ownership and allocation across supported releases | Requires a closed collision corpus, publication history and deployment rejection of unknown/conflicting data; recommended |

Later deployment must compare effective DBC overrides, ranks, scripts, conditions, proc/bonus/threat records, typed
spell references, module identities, applied updates and client hashes against the approved manifest. Reject or
disable Forge before projection if conflicts/unapproved inputs exist. Do not silently overwrite existing rows, mark
updates applied, infer an empty database, or ignore unknown IDs. A hash-only check of repository SQL cannot attest
the contents of an installed DB. This admission check is a future requirement, not implemented enforcement.

## CandidateSpellBlock

| Field | Proposal |
| --- | --- |
| status | CANDIDATE_ONLY |
| start / end | 90000 / 90023 inclusive |
| capacity | 24 |
| targetRelease | ULDuar-V1-PREVIEW-CANDIDATE, documentation-only name |
| allocation owner | Future single Ulduar namespace authority; no owner has reserved these IDs |
| use | Six distinct transport copies for each of four exact family envelopes |
| actionButton24BitCheck | 90023 < 16777216; within the action value field |
| sparseIndexImpact | Compared with native client Spell maximum 80864: 9,159 extra index positions in a max-ID-indexed model |
| server source-model extent | Existing base SQL reaches 100102; candidate does not increase that maximum |

The interval is a bounded, rounded candidate inside an already indexed server-source-model gap, with explicit
negative screens below. Its justification is those screens and limited extent, not that high numbers are free.
No per-family ID mapping or production ownership is assigned. Quarantine/loadout churn is not additional capacity:
24 entries only cover the stated six concurrent copies per family, and no live reuse is authorized.

An index of pointers would add 36,636 bytes at four bytes per entry or 73,272 at eight bytes; these are illustrations,
not measurements of the proprietary client's storage. Server DBC loaders demonstrably size by maximum ID + 1.
Additional objects/auxiliary indexes are outside that calculation. The source-model maximum is not an observed DB.

## Collision evidence and limits

[Machine evidence](ULDuar_A10_NAMESPACE_CANDIDATE_EVIDENCE.json) records input SHA-256 hashes, ID-set fingerprints
and empty intersections with the candidate:

- 50,656 distinct Spell rows across all inspected locale archive versions, not only the conditional winning copy.
- 4,491 conventional base spell_dbc literal row IDs.
- Additional conservative A.8 guards: 4,554 SQL override IDs, 2,801 bound roots and 19,463 referenced numbers.

Reference/historical guards only veto candidates; they are not imported as canonical release occupancy. A.10's
fresh hashes found no change in the A.8/A.9 source/data supporting these inventories. Lexical searches also find
90000 as a cooldown/timer, faction test IDs 90001/90002 and unrelated table keys. Untyped numbers are not SpellID
collisions. Conversely, these screens do not prove dynamic SQL, all positional references or computed IDs absent.
Final reservation must close those typed source-model cases for this exact 24-ID interval, not rescan carrier design.

## Historical exclusions

Design-only conservative tombstones: SpellVisual 16680..16684 and SpellVisualEffectName 7088..7092. The local F/M
registries prove authored experiments but do not prove they were never published. Keep UNKNOWN_HISTORY. Current
patch-U asset installation is local deployment evidence, not a published Ulduar release ledger. SpellVisual 17000
is REFERENCE_ONLY in E; avoid reusing it in that namespace while reconciling those references. None of these typed
visual IDs numerically occupies the Spell namespace. No production tombstone ledger was emitted.

Old UlduarAbilities addon sources describe native spell/rank presentation, not a carrier allocator. Their absence
from the selected release is not retirement of any historical allocations. No unknown published Spell range is
declared free. Require a maintainer-backed supported-history statement/manifests, or explicitly tombstone unresolved
historical Spell uses, before final reservation.

## Remaining narrow gate

1. Close effective client selection for the selected release; conservative union screening already avoids relying
   on one archive winning for this candidate's raw Spell occupancy, but does not establish effective dependencies.
2. Finish the exact interval's typed canonical SQL/reference closure and supported-history/ledger review.
3. In a separately authorized reservation phase, serialize the allocator decision against current hashes/ledger
   revision. This document is not that decision. Changed inputs invalidate its screening.

NO_OFFLINE_EFFECTIVE_WORLD_SNAPSHOT is now an explicit deployment/adoption input requirement under MODEL B,
not a reason to repeat the same local search or redesign the four carriers.
