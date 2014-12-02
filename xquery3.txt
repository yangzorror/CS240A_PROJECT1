for $y in doc("v-depts.xml")/departments/department
let $result := 
  for $i in $y/*
    let $start := $i/@tstart
    let $end := $i/@tend
    where not(compare($start, "1998-05-06")>0 or compare($end, "1988-05-01") < 0)
  return $i
return <result>{$result}</result>