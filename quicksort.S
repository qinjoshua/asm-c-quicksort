         .global main
         .text

//void
//swap(long* xs, long ii, long jj)
//{
//    if (ii != jj) {
//        long tmp = xs[ii];
//        xs[ii] = xs[jj];
//        xs[jj] = tmp;
//    }
//}

// Variable Mappings
// - %rdi is xs
// - %rsi is ii
// - %rcx is jj
// - %r10 is xs[ii] (tmp)
// - %r11 is xs[jj]
swap:
         enter $0, $0

         cmp   %rsi, %rcx
         jne   perform_swap

swap_done:
         leave
         ret

perform_swap:
         mov   (%rdi, %rsi, 8), %r10
         mov   (%rdi, %rcx, 8), %r11
         mov   %r11, (%rdi, %rsi, 8)
         mov   %r10, (%rdi, %rcx, 8)
         jmp   swap_done

//long
//partition(long* xs, long lo, long hi)
//{
//    long pivot = xs[hi - 1];

//    long ii = lo;
//    long jj = lo;
//    for (; jj < (hi - 1); ++jj) {
//        if (xs[jj] < pivot) {
//            swap(xs, ii, jj);
//            ++ii;
//        }
//    }
//    swap(xs, ii, hi - 1);
//    return ii;
// }

// Variable Mappings
// - %rdi is xs (input)
// - %rsi is lo
// - %rcx is hi
// - %rbx is xs
// - %r12 is ii
// - %r13 is jj
// - %r14 is pivot
// - %r15 is hi - 1
partition:
         push  %rbx
         push  %r12
         push  %r13
         push  %r14
         push  %r15
         enter $8, $0
         mov   %rdi, %rbx

         // pivot = xs[hi-1];
         mov   %rcx, %r15
         dec   %r15   
         mov   (%rdi, %r15, 8), %r14
         
         // set ii and jj
         mov   %rsi, %r12
         mov   %rsi, %r13

partition_loop_cond:
         // check if jj is greater than hi - 1 - end if so
         cmp   %r13, %r15
         jle   partition_end

         // run the body of the loop if less than pivot xs[jj]
         cmp   (%rdi, %r13, 8), %r14
         jg    partition_swap

         // increment jj and loop
         inc   %r13
         jmp   partition_loop_cond

partition_swap:
         mov   %r12, %rsi
         mov   %r13, %rcx
         call  swap
         inc   %r12
         inc   %r13
         jmp   partition_loop_cond

partition_end:
         mov   %rbx, %rdi
         mov   %r12, %rsi
         mov   %r15, %rcx
         call  swap
         mov   %r12, %rax

         leave
         pop   %r15
         pop   %r14
         pop   %r13
         pop   %r12
         pop   %rbx
         ret

//void
//quicksort(long* xs, long lo, long hi)
//{
//    if (hi - lo < 1) {
//        return;
//    }

//    long pp = partition(xs, lo, hi);
//    quicksort(xs, lo, pp);
//    quicksort(xs, pp + 1, hi);
//}

// Variable Mappings
// - %rdi, %r13 is xs
// - %rsi, %r14 is lo
// - %rcx, %r15 is hi
// - %r12 is pp
// - %r10 is hi - lo
quicksort:
         push  %r12
         push  %r13
         push  %r14
         push  %r15
         enter $0, $0
         mov   %rdi, %r13
         mov   %rsi, %r14
         mov   %rcx, %r15

         mov   %rcx, %r10
         sub   %rsi, %r10
         
         //mov   $test, %rdi
         //call  printf

         cmp   $1, %r10
         jl    quicksort_end

         //    long pp = partition(xs, lo, hi);
         call  partition
         mov   %rax, %r12
         
         //    quicksort(xs, lo, pp);
         mov   %r13, %rdi
         mov   %r14, %rsi
         mov   %r12, %rcx
         call  quicksort
         
         //    quicksort(xs, pp + 1, hi);
         mov   %r13, %rdi
         inc   %r12
         mov   %r12, %rsi
         mov   %r15, %rcx
         call  quicksort
         
quicksort_end:
         leave
         pop   %r15
         pop   %r14
         pop   %r13
         pop   %r12
         ret

//void
//read_int(long* ptr)
//{
//    if (scanf("%ld", ptr) != 1) {
//        puts("bad input");
//        exit(1);
//    }
// }

// Variable Mapping
// - %rdi is $"%ld"
// - %rsi is ptr

read_int:         
         enter $0, $0

         mov   %rdi, %rsi
         mov   $scanfmt, %rdi
         mov   $0, %al
         
         call  scanf
         
         cmp   $1, %rax
         jne   read_int_abort
         
         leave
         ret

read_int_abort:
         mov   $bad_input, %rdi
         call  puts
         call  abort
         

//int
//main(int _argc, char* _argv[])
//{
//    long nn;
//    read_int(&nn);

//    long* xs = malloc(nn * sizeof(long));

//    for (long ii = 0; ii < nn; ++ii) {
//        read_int(&(xs[ii]));
//    }

//    quicksort(xs, 0, nn);

//    printf("%ld\n", nn);
//    for (long ii = 0; ii < nn; ++ii) {
//        printf("%ld ", xs[ii]);
//    }
//    printf("\n");

//    free(xs);
//    return 0;
// }

// Variable Mapping
// - %rsp/%r12 is nn
// - %rcx is nn * sizeof(long)
// - %r13 is xs
// - %r14 is ii
main:
         push  %r12
         push  %r13
         push  %r14
         enter $8, $0

         lea   0(%rsp), %rdi
         call  read_int
         mov   0(%rsp), %r12

         // nn * sizeof(long)
         mov   $8, %rcx
         imul  %r12, %rcx

         // long* xs = malloc(nn * sizeof(long));
         mov   %rcx, %rdi
         call  malloc
         mov   %rax, %r13

         // for (long ii = 0; ii < nn; ++ii) {
         //    read_int(&(xs[ii]));
         // }
         mov   $0, %r14

main_loop_check_cond:
         cmp   %r14, %r12
         jle   main_loop_check_done

         lea   0(%r13, %r14, 8), %rdi
         call  read_int

         inc   %r14
         jmp   main_loop_check_cond

main_loop_check_done:

         // quicksort(xs, 0, nn);
         mov   %r13, %rdi
         mov   $0, %rsi
         mov   %r12, %rcx

         call  quicksort

         //    printf("%ld\n", nn);
         mov   $printlen, %rdi
         mov   %r12, %rsi
         call  printf

         // for (long ii = 0; ii < nn; ++ii) {
         //    printf("%ld ", xs[ii]);
         // }
         // printf("\n");
         mov   $0, %r14

main_loop_print_cond:
         cmp   %r14, %r12
         jle   main_loop_print_done

         mov   $printfmt, %rdi
         mov   (%r13, %r14, 8), %rsi

         call  printf

         inc   %r14
         jmp   main_loop_print_cond

main_loop_print_done:
         mov   $printbrk, %rdi
         call  printf

         mov   %r13, %rdi
         call  free

main_done:
         leave
         pop   %r14
         pop   %r13
         pop   %r12
         ret

         .data
bad_input: .string "bad input"
scanfmt: .string "%ld"
printfmt:.string "%ld "
printbrk:.string "\n"
printlen:.string "%ld\n"
