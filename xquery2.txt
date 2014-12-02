for $emp in doc("v-emps.xml")/employees/employee
let $name := concat($emp/firstname, ' ', $emp/lastname)
for $x in $emp/salary
let $end := $x/@tend
let $start := $x/@tstart
for $dept in $emp/deptno
let $dend := $dept/@tend
let $dstart := $dept/@tstart
where $x < 52000 and 
compare($end, "1991-01-06") >= 0 and compare($start, "1991-01-06") <= 0 and 
compare($dend, "1991-01-06") >= 0 and compare($dstart, "1991-01-06") <= 0
group by $emp
for $y in doc("v-depts.xml")/departments/department
where $y/deptno = $dept
return <result name="{distinct-values($name)}" department="{distinct-values($y/deptname)}">{$x}</result>