"""Dependency-free descriptive aggregation."""
import math
def wilson(successes, total):
    if not total:return None
    z=1.96;p=successes/total;d=1+z*z/total;c=(p+z*z/(2*total))/d;h=z*math.sqrt(p*(1-p)/total+z*z/(4*total*total))/d
    return [c-h,c+h]
def binary(values):
    observed=[v for v in values if v is not None]; hits=sum(observed)
    return {'count':len(observed),'successes':hits,'rate':hits/len(observed) if observed else None,'wilson_95':wilson(hits,len(observed))}

def continuous(values):
    values=sorted(v for v in values if v is not None)
    if not values:return {'count':0,'median':None,'iqr':None}
    def median(items):
        n=len(items); return (items[(n-1)//2]+items[n//2])/2
    middle=len(values)//2
    lower=values[:middle]; upper=values[(len(values)+1)//2:]
    return {'count':len(values),'median':median(values),'iqr':[median(lower),median(upper)] if lower and upper else None}

def matrix(trials, metric):
    """Keep task/condition/fingerprint cells separate; incomplete stays visible."""
    result={}
    for trial in trials:
        key=(trial.get('task_id'),trial.get('condition_id'),trial.get('experiment_fingerprint'))
        result.setdefault(key,[]).append(trial.get(metric))
    return {key: binary(values) for key,values in result.items()}

def summarize(rows):
    """Keep all declared cells visible; exclude incomplete observations."""
    complete = [row for row in rows if row.get("evidence") == "complete"]
    successes = [row.get("success") == "pass" for row in complete]
    return {"planned": len(rows), "complete": len(complete), "incomplete": len(rows) - len(complete), "task_success": binary(successes)}

def metric_summaries(records):
    result = {}
    for record in records:
        for name, observation in record.get("metrics", {}).items():
            entry = result.setdefault(name, {"observed": [], "unavailable": 0})
            if isinstance(observation, dict) and observation.get("status") == "observed":
                entry["observed"].append(observation.get("value"))
            else:
                entry["unavailable"] += 1
    return {name: {"summary": binary(values) if all(isinstance(value, bool) for value in values) else continuous(values), "unavailable": entry["unavailable"]} for name, entry in result.items() for values in [entry["observed"]]}
