# Preserved Oct 24 refresh + generation lifecycle

## Provenance and scope

Origin: https://github.com/andrew-bierman/Prysm.git

Remote main/base verified before publication: `2ba9abcd601593d614391ab59579f9008c6efac2`.
Recovered source: `integration/oct24-preserved-20261025`, exact fetched SHA `19055bb62f1be43bbb36d029e4318ee3aaa282b3` (parent `bebbd529f157de967aafa1453fa2e022326c8885`).
Integration branch: `integration/prysm-refresh-lifecycle-20261025`.
Original lifecycle branch/head remains intact: `codex/prysm-generation-lifecycle-20261025` / `6124489675b951b2bf0d2b1caad6d528d228f933`.

Integrated targeted view-model hunks and new test methods, rather than replacing recovered files. Of the 28 files owned by the recovered snapshot, 26 remain byte-identical. The two overlapping files retain the recovered availability guards plus the reviewed lifecycle implementation/tests. No unrelated `prysm-openai-feature/` content is tracked. iOS deployment stays 18.0. Shared Bierman Collective policy links, lifted draft/selection state, removal of the misleading autosave setting, and OS fallback remain unchanged from the snapshot. No policy hosting/content was changed.

## Behavior and review

All eight example paths use a main-actor lifecycle guard: blank/overlapping/pre-cancelled requests are rejected; model availability is rechecked with recovery guidance; old typed results are cleared; errors reset loading; cancelled or cleared operations cannot publish late content/errors. Typed result publication runs synchronously before releasing loading. Clearing invalidates delivery but does not cancel the underlying operation. UI dismissal still does not cancel its unstructured generation task.

Ten added Swift test declarations (12 cases, including two parameterized tests) cover unavailable entry points/reasons, availability recovery, blank/overlapping calls, failure/retry, thrown/self cancellation, suspended external cancellation and clear with late success/error, and typed replacement under the loading guard. New tests preserve OS availability annotations. These exercise shared lifecycle behavior without real model calls; they do not validate generated content quality or UI behavior.

Independent read-only review of the original patch found and prompted fixes for clear-while-suspended resurrection and publication outside the loading guard. The integrated patch also received independent source review.

## Validation and limits

Passed local source-contract assertions: all 28 recovered files preserved as described above; reviewed lifecycle source exact except OS annotations; all test methods guarded; eight publishers; cancellation/revision ordering; iOS18 deployment; absence of unrelated feature tree. `git diff --check` passed. No expensive suites rerun.

Swift and Xcode are absent in this cloud environment. **Swift tests, typechecking, Apple builds, real model generation, native UI interactions, and Duo acceptance are unrun here.** Recovered guards are present but compilation is not qualified by static checks.

Outgoing history/source scanned with existing Python credential-signature and high-entropy-literal checks before push. No dedicated secret scanner installed. Heuristics are not proof of secret absence; scan results are reported with publication handoff. Earlier GraphQL PR listing was Forbidden; any new denial must stop the PR action without an alternate access path.

## Apple lane next action / release gates

1. Fetch the published integration branch and verify its exact head from the handoff. Build with Xcode 26, iOS18 minimum; run all relevant unit/UI tests, including the guarded lifecycle and recovered selection tests. Confirm unsupported-OS fallback without FoundationModels initialization.
2. On eligible hardware, generate all seven structured examples and quick text, exercise not-ready/disabled/unsupported states and recovery, failures, retries, overlapping calls, and cancellation. Check UI-dismissal task ownership as a remaining issue.
3. Validate draft and selection continuity across compact/regular transitions and sheets. Assess background/relaunch expectations explicitly: recovered draft state is in-memory; no durable autosave promise is made.
4. Validate shared policy links in native Settings and complete native UI/Duo acceptance. No launch-readiness claim until Apple evidence is recorded.

Publication scope is one new branch and one draft PR only; no merge, deployment, new credential, App Store action, or customer-data mutation is authorized.
