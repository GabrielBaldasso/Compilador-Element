@.str0 = private unnamed_addr constant [15 x i8] c"Maior de idade\00"
@.str1 = private unnamed_addr constant [15 x i8] c"Menor de idade\00"
@.fmt_int = private constant [4 x i8] c"%d\0A\00"
@.fmt_float = private constant [4 x i8] c"%f\0A\00"
@.fmt_scan = private constant [3 x i8] c"%d\00"
@.fmt_scanf_float = private constant [3 x i8] c"%f\00"
@.fmt_scanf_char = private constant [3 x i8] c"%c\00"
declare i32 @printf(i8*, ...)
declare i32 @scanf(i8*, ...)
; === Global Strings serão adicionadas no final ===

define i32 @main() {
  %t1 = alloca i32
  store i32 17, i32* %t1
  %t2 = icmp ne i32 idade>=18, 0
  br i1 %t2, label %label1, label %label2
label1:
  %t3 = getelementptr inbounds [15 x i8], [15 x i8]* @.str0, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %t3)
  %t4 = getelementptr inbounds [15 x i8], [15 x i8]* @.str1, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %t4)
  br label %label3
label2:
  br label %label3
label3:
  ret i32 0
}
