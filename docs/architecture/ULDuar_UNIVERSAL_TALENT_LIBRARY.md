# Ulduar universal talent library

Status: architecture and data requirements, 2026-09-14. Final visual layout remains undecided.

## Ownership and compatibility are independent

`selectionAllowed = published AND supported AND validRank AND sufficientBudget AND genericPrerequisites`.
There is no source class, native TalentTab, original tier or current matching-spell check in this expression.
An optional new prerequisite must have a generic design rationale; native tree position is not imported as policy.

Owned talents have a separately derived compatibility state:

| State | Meaning | Behavior |
| --- | --- | --- |
| ACTIVE | At least one eligible current ability/effect or declared character subject matches | Rule installed |
| DORMANT | Owned and supported; no compatible ability/subject currently exists | Ownership/rank retained |
| UNSUPPORTED | Required runtime feature missing or definition withdrawn | Preserve record; no rule execution |

Unowned is an ownership state, not DORMANT. A supported unowned talent can show its potential matches and remains
selectable with zero matches. Character-wide health/armor rules match the character domain and can be ACTIVE with
an empty spellbook. A combat condition or proc chance need not currently be true for a talent to be ACTIVE.

Required example: learn +15% Periodic Frost Damage with zero matching abilities -> DORMANT. Later install a
supported Frost conversion and periodic transformation on a damaging ability -> same owned rank becomes ACTIVE.
Removing the last matching ability -> DORMANT. None of these transitions debits points or relearns a native talent.

Do not persist ACTIVE/DORMANT as authority. Derive it from owned rank, catalog/build revision, structural ability
graphs and required mechanic grants. Cache matching effect keys and reasons. Invalidate on learn/unlearn, native
rank change, gem apply, keystone change, loadout change, mechanic grant changes, login and catalog publication.
Equipment/aura changes invalidate only dependencies they can affect; dynamic hit conditions use event evaluation.

Learning a supported talent whose effect grants an ability uses character-domain eligibility and validates the
grant before evaluating its resulting ability selectors. Do not create a circular requirement that the player
already know the very ability the talent grants. Grant/revoke and derived state publish in one build revision.

## Server and client components

Server library service owns the published catalog, rule support manifest, selection validator, point ledger and
compatibility evaluator. `mod-ulduar-abilities` provides effective ability/effect snapshots and resolver previews.
Client components: catalog cache, search/filter model, owned-state model, draft changes, preview adapter and views.

Reuse the existing separation of committed state and draft in
[DraftBuild.lua](../../client/Interface/AddOns/UlduarAbilities/DraftBuild.lua). Reuse widgets where useful without
binding the new system to the current per-ability tree. Existing Abilities UI remains usable during migration.
Native talent frame behavior is not the authority for catalog, ownership or spending.

Catalog entry DTO:

```text
definitionId, catalogVersion, nameKey/resolvedName, iconRef, generalizedTooltip
category in {Offense, Defense, Control, Sustain, Mobility, Resource, Summons, Utility}
tags, maxRank, rankValueVectors, pointCosts, prerequisites, requiredCapabilities
publicationState, supportState, unsupportedReason
debugSourceRefs (developer permission only; source class/tab/talent/rank/spell IDs)
```

Owned-state DTO:

```text
definitionId, ownedRank, buildRevision, owned, compatibilityState
matchingAbilityIds, matchingEffectKeys, compatibilityReason
currentBudget, proposedRank, proposedCost, selectionAllowed, rejectionReasons
```

An entry shows icon, generalized name and tooltip, current/max rank, tags/category, ACTIVE/DORMANT state when
owned, affected abilities and support explanations. Player-facing ownership does not require original class labels.
Developer views can trace every original talent/rank; debug fields cannot control player eligibility.

Search covers localized generalized names/descriptions and tags. Filters combine categories and semantic facets:
Damage, Healing, Defense, Utility, Fire, Frost, Shadow, Physical, Projectile, Periodic, Melee, Pet, Resource,
Triggered and the rest of the taxonomy. Define AND across filter groups, OR within a group, with visible active
filters. Offer Owned, Available and Unsupported filters. Unsupported entries are visible with reasons and disabled
purchase controls. DORMANT is informational and does not disable a supported purchase.

Do not evaluate arbitrary selector ASTs in the addon. Server returns affected abilities and resolved tooltip
numbers; client can filter a catalog cache by published tags. Draft previews include before/after state and costs.
Commit failure restores/refreshes authoritative state and shows a reason; stale drafts are never silently rebased.

## Transport data requirements

Use a distinct versioned classless protocol namespace over the authenticated game session. Logical operations:
HELLO/CAPABILITIES, CATALOG_PAGE, OWNED_SNAPSHOT, PREVIEW_BUILD, COMMIT_BUILD and BUILD_CHANGED.
Catalog version/hash and locale key govern cache validity. Owned state is session-scoped and refreshed at login.

Current Ulduar transport limits whole addon prefix plus payload to 255 bytes. Large tooltips, prerequisites and
snapshots require bounded chunking/pagination with message ID, chunk ordinal/count, expiry and total-size limits.
Default proposed logical message ceiling 64 KiB, maximum 256 chunks and at most two partial assemblies per session;
the fragment encoder must account for header overhead. Reject duplicate/conflicting chunks. Compressing must not
bypass decompressed-size bounds. Search requests have bounded text length, page size and rate limits.

Keep uint64 IDs/revisions as decimal strings in Lua 5.1 where double precision cannot represent every value.
Cache data is presentation only; transmitted points, matching counts and costs are never trusted for mutations.
See [classless architecture](ULDuar_CLASSLESS_ARCHITECTURE.md) for transactional protocol semantics.

## Proposed talent schema

| Table | Key | Essential fields |
| --- | --- | --- |
| `ulduar_talent_definition` | version, talent_id | category, tags, text/icon, max rank, classification/support |
| `ulduar_talent_rank` | version, talent_id, rank | cost, complete value vector, semantic variant |
| `ulduar_talent_selector` | version, selector_id | subject, typed AST, binding name, snapshot stage |
| `ulduar_talent_trigger` | version, trigger_id | event/phase, chance model, ICD, proc policy |
| `ulduar_talent_condition` | version, condition_id | typed AST, subject, evaluation time |
| `ulduar_talent_effect` | version, talent_id, rank, effect_id | operation, selector/trigger/condition refs, payload |
| `character_ulduar_talents` | guid, loadout_id, talent_id | rank, acquired_version, grant_source, revision |

Additional `ulduar_talent_modifier` stores modifier ID, operation/property/domain/unit/value/group for effect rows.
`ulduar_talent_prerequisite` stores an acyclic generic requirement AST. `ulduar_talent_source` maps every native
TalentID/rank/SpellID plus corpus hash to a canonical definition or unresolved/tombstone record. The source mapping
is many-to-many to support semantic splits; a rank's full source behavior must be accounted for across those edges.
Store original class/tab/tier only in provenance. Index owned rows by guid/loadout and catalog rows by category/tag.

Composite versioned FKs prevent joining a rank to a different catalog revision. Character references to world
catalogs are application-validated across databases. Rank bounds, duplicate aliases, prerequisite cycles and point
totals are validated on publication and every commit. An owned withdrawn definition remains recoverable history.

## Acceptance scenarios

One character buys supported talents from all ten WotLK classes without source-class gates. Empty spellbook can
buy a spell-selector talent and see DORMANT. Gem conversion activates the already owned talent. Hybrid effects
match only the intended payload. Reload/reconnect retains rank without duplicating rules. A forged ACTIVE flag,
client cost or catalog version cannot authorize purchase. Unsupported ranks remain visible and unselectable.
These scenarios define later validation, not claimed runtime results.
