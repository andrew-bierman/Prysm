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

## Oct 30 dismissal cancellation follow-up

At 2026-10-30 13:43:13 UTC the review branch was verified at `87a6828a0575d135b859c0697c2363267bfc7ce0`. Local work fast-forwarded to preserve both newer Apple-lane commits. Those commit messages report successful native unit/UI and Release validation; this cloud task did not independently inspect their artifacts or rerun them.

Source inspection confirmed ExampleDetailView still launched an unowned Task. It now retains one generation task, rejects duplicate scheduling before the view model enters loading, cancels immediately on Close and on disappearance (including swipe dismissal), and clears its task handle after completion. Whitespace-only input is disabled consistently with the existing model guard. Model/policy/draft logic is unchanged. Cancellation remains cooperative; loading is retained until the provider completes, and existing model guards suppress late delivery.

Added one guarded regression test for cancellation before generation begins, preserving previous results and never invoking provider/publisher. Existing continuation-controlled tests cover cancellation during a suspended provider with late success/error. These model tests do not establish SwiftUI dismissal behavior.

Cloud validation: source checks and `git diff --check` only. New Swift test and SwiftUI changes are uncompiled/unrun here; Swift/Xcode absent. No duplicate or native build started. Parent must coordinate Mini availability (currently assigned to Miradita) before Apple validation: build/test the exact new head, exercise Close and interactive dismissal both immediately after Generate and during generation, reopen another example, verify no late result/error or stuck loading after provider completion, then resume older-OS runtime/live-AI/Duo gates. No repeated GraphQL request; prior Forbidden remains unresolved. Publication is to the existing review branch only, with no merge/release.

## Deterministic active-generation UI acceptance fixture

Parent reports Mini verified `db9651bc` native compilation, 41 unit tests, and focused keyboard/selection/Close/swipe/reopen UI coverage (exit 0 at Oct30 14:37:10 UTC). These reports are not new cloud runs. Two additional attempts have been used; **one remains, owned/coordinated by parent**. This task dispatched none and does not reset that count.

Existing unit coverage proves pre-start cancellation skips operation/publication, suspended-provider cancellation suppresses late success/error, and loading cleans up. Previous UI coverage did not start generation, so it did not establish that dismissal cancels an active task.

Prepared a Debug-only, explicit `--ui-test-generation-cancellation` host with an in-memory view model whose availability closure returns available. It presents the real ExampleDetailView and injects a cancellation-aware 60-second synthetic operation through its existing lifecycle helper; no LanguageModelSession, system-model query, network, credential or persisted-setting write occurs in this host. New injection and launch routing are excluded from Release. Natural completion is intentionally longer than the test timeout, so cancelled-count assertions cannot pass merely because a short fake finished.

Exact next test: `PrysmUITests/ActiveGenerationCancellationTests/testCloseAndSwipeCancelActiveGeneration` in Debug on iOS26+ simulator. It starts generation, observes loading and disabled Generate, uses Close, requires cancellation completion/idle/no error/no result, repeats with a sheet-length swipe, then reopens. It covers SwiftUI task ownership with a cooperative fake. Existing unit tests cover a non-cooperative provider's late completion; real FoundationModels cancellation latency/quality still requires eligible-device acceptance.

Cloud source review/static checks only; new fixture and UI test remain uncompiled/unrun. Parent decides whether to use the remaining native attempt; do not dispatch concurrent/duplicate runs. No production cancellation correction was identified from current evidence; this patch supplies missing deterministic acceptance coverage only. Existing GraphQL failure remains untouched.
