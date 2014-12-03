let $x :=
  for $emp in doc("v-emps.xml")/employees/employee
  where $emp/firstname[1]="Kyoichi" and $emp/lastname[1]="Maliniak"
  return $emp
for $deptno in $x/deptno

  for $dept in doc("v-depts.xml")/departments/department
  where $dept/deptno[1] = $deptno
  
return
<department tstart="{$deptno/@tstart}" tend="{$deptno/@tend}" deptno="{$deptno}">
{
  $dept/deptname
}
</department>