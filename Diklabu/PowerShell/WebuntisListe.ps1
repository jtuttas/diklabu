$c = Get-UntisCourses
$t= Get-Untisteachers

foreach ($course in $c) {
  
  foreach ($teacher in $t) {
    if ($course.teacher1 -eq $teacher.id) {
        $course.teacher1=$teacher.name
    }
  }  
}