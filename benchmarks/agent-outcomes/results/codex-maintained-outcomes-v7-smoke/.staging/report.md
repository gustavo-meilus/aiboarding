# Agent outcome benchmark

## Measured facts

| Task | Condition | Success | Evidence |
| --- | --- | --- | --- |
| command-discovery | none | pass | complete |
| command-discovery | aiboarding-full | pass | complete |
| architecture-boundary | aiboarding-full | incomplete | incomplete |
| architecture-boundary | none | incomplete | incomplete |
| domain-invariant | aiboarding-full | pass | complete |
| domain-invariant | none | fail | complete |
| known-failure-mode | none | pass | complete |
| known-failure-mode | aiboarding-full | incomplete | incomplete |
| escalation | none | incomplete | incomplete |
| escalation | aiboarding-full | incomplete | incomplete |
| nested-instructions | none | incomplete | incomplete |
| nested-instructions | aiboarding-full | incomplete | incomplete |

## Coverage

Planned trials: 12; complete: 5; incomplete: 7.
task_success: {'count': 5, 'successes': 4, 'rate': 0.8, 'wilson_95': [0.3755282641185388, 0.9637768390302125]}; unavailable: 0.
completion_claim: {'count': 5, 'successes': 0, 'rate': 0.0, 'wilson_95': [-2.7755575615628914e-17, 0.43449149475208104]}; unavailable: 0.
invalid_commands: {'count': 5, 'median': 0.0, 'iqr': [0.0, 0.0]}; unavailable: 0.
tool_calls: {'count': 5, 'median': 5.0, 'iqr': [4.5, 5.5]}; unavailable: 0.
retries: {'count': 5, 'median': 0.0, 'iqr': [0.0, 0.0]}; unavailable: 0.
elapsed_time: {'count': 0, 'successes': 0, 'rate': None, 'wilson_95': None}; unavailable: 5.
usage: {'count': 0, 'successes': 0, 'rate': None, 'wilson_95': None}; unavailable: 5.
interventions: {'count': 5, 'median': 0.0, 'iqr': [0.0, 0.0]}; unavailable: 0.
violations: {'count': 0, 'successes': 0, 'rate': None, 'wilson_95': None}; unavailable: 5.
false_completion: {'count': 5, 'successes': 0, 'rate': 0.0, 'wilson_95': [-2.7755575615628914e-17, 0.43449149475208104]}; unavailable: 0.

## Interpretation

Results are task- and runtime-bound; this maintained corpus does not establish universal coding-agent or foundation-model quality. No improvement claim is made without complete objective evidence.
