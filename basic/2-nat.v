﻿(* Стандартная библиотека также определяет тип nat *)
Check 2.
(* 2: nat *)

Check S(S(O)).
(* 2: nat - такого на нестандартном типе nat нет *)


Example test_mult22: (mult (S(S O)) (S(S O)) ) = (S(S(S(S O)))).
Proof. simpl. reflexivity. Qed.
Example test_mult33: (mult 3 3 ) = 9.
Proof. simpl. reflexivity. Qed.

(* simpl - упростить выражение; reflexivity проверить на равенство
Т.к. reflexivity может само упростить выражение, 
то simpl не нужен и полезен только при отладке,
чтобы видеть состояние после упрощения

0 + n = n он доказать может, а вот симметрично n + 0 = n - нет
 *)

Theorem plus_O_n : forall n : nat, 0 + n = n.
Proof.
  intros n.
  simpl. reflexivity. Qed.

(* n = m ->
это условие на переменные n и m
*)
Theorem plus_id_example: forall n m: nat, n = m -> n + n = m + m.
Proof.
intros n m.
intros H.
(* Используем тактику rewrite *)
rewrite -> H.
reflexivity.
Qed.

(* rewrite -> plus_O_n перезаписывает левое условие уже доказанной теоремой
*)
Theorem mult_0_plus : forall n m : nat,
  (0 + n) * m = n * m.
Proof.
  intros n m.
  rewrite -> plus_O_n.
  reflexivity.
Qed.

(* Обратите внимание на то, что происходит при rewrite -> H
Он перезаписывает, фактически, обе стороны выражения в одной операции
 *)
Theorem mult_S_1 : forall n m : nat,
  m = S n ->
  m * (1 + n) = m * m.
Proof.
	intros n m.
	intros H.
	rewrite -> H.
	reflexivity.
Qed.

(* Тактика rewrite заключается в следующем
intros H переносит гипотезу в контекст доказательства
rewrite -> H. говорит о том, что нужно переписать в соответствии с гипотезой левую часть уравнения
rewrite <- H. говорит о том, что нужно переписать правую часть (разницу видно при пошаговом исполнении)
 *)

Theorem plus_id_example2: forall n m: nat, n = m -> n + n = m + m.
Proof.
intros n m.
intros H.
(* Используем тактику rewrite *)
rewrite <- H.
reflexivity.
Qed.

(* Здесь в теореме определяется сразу два условия: n = m и m = k *)
Theorem plus_id_example3: forall n m k: nat, n = m -> m = k -> n + m = m + k.
Proof.
intros n m k.
(* Загружаем обе гипотезы *)
intros H1 H2.
(* Используем тактику rewrite дважды *)
(* Первой гипотезой переписываем левую часть, а второй - правую *)
rewrite -> H1.
rewrite <- H2.
reflexivity.
Qed.

(* Тактику destruct смотреть ниже в plus_0_n_Vin3 *)


(*
Эту функцию можнобыло бы определить как в 2.v, но тут, для эксперимента берём вложенные match
Функция неверная, см. комментарии в функции
 *)
Fixpoint plusVin(n m : nat) : nat :=
  match n with
	| O => 
		match m with
			| O    => n
			| _    => m
		end
	| S n' =>
		match m with
			(* Если сюда поставить S (plusVin n' O) или другой вызов plusVin - не поймёт
				The reference plusVin was not found in the current environment.
				Впечатление, что он считает, 
				что в любом match должна быть одна ветка без рекурсии *)
			| O    => n
			| S m' => S (plusVin n' m')
		end
  end.

(* Функцию даже верно определить в симметричном варианте не удаётся *)
Fixpoint plusVinA(n m : nat) : nat :=
  match n with
	| O => 
		match m with
			| O    => O
			| S m' => S (plusVinA O m')
		end
	| S n' =>
		match m with
			(* Если сюда поставить S (plusVin n' O) или другой вызов plusVin - не поймёт
				Cannot guess decreasing argument of fix.
				Функция plusVin абсолютно аналогична, но из-за теоремы ниже ошибки разные
				То есть с выводом ошибок всё не так просто:
				может быть выведена следующая за определением ошибка *)
			| O    => S (n')
			| S m' => S (plusVinA n' m')
		end
  end.

Theorem plusVin_O_O : forall n : nat, (plusVin O O) = O.
Proof.
  intros n.
  simpl. reflexivity. Qed.
  
Theorem plusVin_O_1 : forall n : nat, (plusVin O (S(O))) = S(O).
Proof.
  intros n.
  simpl. reflexivity. Qed.
(* Тоже не может, хотя 0 + n = n доказывает
Theorem plusVin_O_n : forall n : nat, (plusVin O n) = n.
Proof.
  intros n.
  simpl. reflexivity. Qed.
*)
(* К сожалению, эту теорему он доказать не может
Theorem plus_m_n : forall n m : nat, (plusVin m n) = (plusVin n m).
Proof.
  intros n m.
  simpl. reflexivity. Qed.
*)

(* На этой функции выдаёт ошибку:
 Cannot guess decreasing argument of fix.
 Похоже, рекурсивный аргумент должен быть только один
 *)
(*
Fixpoint plusVin2(n m : nat) : nat :=
  match n, m with
	| O,    O    =>  O
	| O,    S m' => S (plusVin2 O m')
	| S n', O    => S (plusVin2 n' O)
	| S n', S m' => S (plusVin2 n' m')
  end.
*)

(*
Теоремы n+0=n и 0+n=n для этой функции будет доказать проще,
чем для более стандартной plusVin4
Т.к. в данном случае при использовании тактики destruct n
оба варианта для n сразу же определены
Т.е. если есть возможность определить функцию так,
что при разложении тактикой destruct параметра n, 
значение функции будет определено для всех вариантов n хоть когда-нибудь для других значений,
это уже может быть хорошо хотя бы для частных случаев
*)
Fixpoint plusVin3(n m : nat) : nat :=
  match n, m with
	| O,    O    => O
	| O,    S m' => m
	| S n', O    => n
	| S n', S m' => S (S (plusVin3 n' m'))
  end.


Theorem plus_0_0_Vin3 : forall n : nat, (plusVin3 0 0) = 0.
Proof.
  intros n.
  simpl. reflexivity. Qed.

(* С функцией plusVin3 тоже не получается доказать, что 0+n = n *)
(*
Theorem plus_0_n_Vin3 : forall n : nat, (plusVin3 0 n) = n.
Proof.
  simpl.
  reflexivity.
Qed.
 *)

(*  --------------------------------------------------------------------------------
Тактика  destruct
Мы разбиваем переменную n: nat на две части, как она определена
Грубо говоря, это множество вариантов [O | S(n': nat)]
При этом as [| n'] говорит, 
что в первый конструктор не передаётся никаких подстановок (т.к. он без параметров),
а во второй конструктор S(n') передаётся подстановка n',
то есть в дальнейшем это будет переменная n'

eqn:E - это, по сути, именование гипотезы n=O или n=S(n')

Далее каждый путь проходим отдельно, разделяя его оператором "-"
(оператор называется "пуля" [bullets])

При вложенных destruct пули чередуются с "-", "+", "*"
(не понял, есть ли какой-то обязательный порядок)
Также вместо пуль можно заключать подзадачи в скобки, см. ниже plus_n_0_Vin3,
причём скобки совместимы с пулями на других уровнях,
то есть в теореме можно использовать и то, и то
*)
Theorem plus_0_n_Vin3 : forall n : nat, (plusVin3 0 n) = n.
Proof.
  intros n.
  destruct n as [| n'] eqn:E.
  - (* E: n = 0 *)
  simpl.
  reflexivity.
  - (* E: n = S n' *)
  simpl.
  reflexivity.
Qed.

Theorem plus_n_0_Vin3 : forall n : nat, (plusVin3 n 0) = n.
Proof.
  intros n.
  {
	  destruct n as [| n'] eqn:E.
	  {
		simpl.
		reflexivity.
	  }
	  {
		simpl.
		reflexivity.
	  }
  }
Qed.

(* Доказательство, полностью идентичное тому, что выше,
но записанное более кратко
"Пули" (знаки "-") опущены, что не рекомендуется
После доказывания одной ветки, Coq просто считает,
что следующая команда уже относится к другой ветке
*)
Theorem plus_n_0_Vin3_2 : forall n : nat, (plusVin3 n 0) = n.
Proof.
  intros n.
  destruct n.
  reflexivity.
  reflexivity.
Qed.

(*
Ещё более кратко записанное доказательство, абсолютно идентичное выше
intros [|n'] является сокращением для intros n. destruct n as [|n'].
Однако, eqn:E теперь записать уже не где (если он нужен)
*)
Theorem plus_n_0_Vin3_3 : forall n : nat, (plusVin3 n 0) = n.
Proof.
  intros [|n'].
  reflexivity.
  reflexivity.
Qed.

(*
intros [] - если мы хотим избежать указания аргументов
Если аргументов несколько, их можно поделить сразу: intros [] [].
*)
Theorem plus_n_0_Vin3_4 : forall n : nat, (plusVin3 n 0) = n.
Proof.
  intros [].
  reflexivity.
  reflexivity.
Qed.

(* К сожалению, эту теорему он тоже доказать одним reflexivity не может *)
(*
Theorem plus_m_n : forall n m : nat, (plusVin3 m n) = (plusVin3 n m).
Proof.
  intros n m.
  simpl. reflexivity. Qed.
*)

(*
На последней ветке нужно доказать, что
S (S (plusVin3 m' n')) = S (S (plusVin3 n' m'))

Это нужно делать по индукции, но я пока не знаю как
*)
(*
Theorem plus_m_n : forall n m : nat, (plusVin3 m n) = (plusVin3 n m).
Proof.
  intros n m.
  destruct n as [|n'].
-
  destruct m as [|m'].
  +
  simpl. reflexivity.
  +
  simpl. reflexivity.
-
  destruct m as [|m'].
  +
  simpl. reflexivity.
  +
  simpl. reflexivity.
Qed.
*)

Fixpoint plusVin4(n m : nat) : nat :=
  match n with
	| O    => m
	| S n' => S(plusVin4 n' m)
  end.

(* А вот это он доказывает на ура
Т.е. симметричное определение plusVin3 операции сложения для него более сложное,
чем несимметричное plusVin4
 *)
Theorem plus_0_n_Vin4 : forall n : nat, (plusVin4 0 n) = n.
Proof.
  intros n.
  simpl. reflexivity.
Qed.

(* С другой стороны, симметричное определение plusVin3
легко доказывает теорему ниже, а здесь возникают трудности
*)
(*
Theorem plus_n_0_Vin4 : forall n : nat, (plusVin4 n 0) = n.
Proof.
  intros n.
  destruct n.
  -
  simpl. reflexivity.
  -
  simpl. reflexivity.
Qed.
*)

(*
Учебные доказательства из учебника
eqb сравнивает два натуральных числа
Теорема: для любых n верно 0 != n + 1
*)
Fixpoint eqb (n m : nat) : bool :=
  match n with
  | O => match m with
         | O => true
         | S m' => false
         end
  | S n' => match m with
            | O => false
            | S m' => eqb n' m'
            end
  end.

Notation "x =? y" := (eqb x y) (at level 70) : nat_scope.
Theorem zero_nbeq_plus_1 : forall n : nat,
  0 =? (n + 1) = false.
Proof.
	intros [].
	* simpl. reflexivity.
	* simpl. reflexivity.
Qed.

Theorem Ex1: forall b c: bool, b = true -> c = true -> andb b c = true.
Proof.
	intros b c.
	intros H1 H2.
	rewrite -> H1. rewrite -> H2.
	simpl. reflexivity.
Qed.

(*
Учебные доказательства из учебника
Если b and c == true, то c == true
Обратим внимание на то, что rewrite <- H перезаписывает значения true на значения andb b c

При решении задачи используем это
Подставляем в c = true операцию andb b c
Когда операция andb b c не равна true, с также не равен true
Поэтому, случайно, это доказательство работает и считается корректным
В принципе, доказательство немного мошенническое, я бы сказал, т.к. оно доказывает немного другое, более общее, утверждение
*)

Theorem andb_true_elim2 : forall b c : bool,
  andb b c = true -> c = true.
Proof.
	intros b c.
	intros H.
	destruct b as [] eqn:E.
	* destruct c as [] eqn:F.
		+ simpl. reflexivity.
		+ rewrite <- H. simpl. reflexivity.
	* destruct c as [] eqn:F.
		+ rewrite <- H. simpl. reflexivity.
		+ rewrite <- H. simpl. reflexivity.
Qed.

(*
Можно доказать такую забавную теорему, она идентична предыдущей
*)
Theorem andb_true_elim2_2 : forall b c : bool,
  andb b c = true -> c = andb b c.
Proof.
	intros b c.
	intros H.
	destruct b as [] eqn:E.
	* destruct c as [] eqn:F.
		+ simpl. reflexivity.
		+ rewrite <- H. simpl. reflexivity.
	* destruct c as [] eqn:F.
		+ rewrite <- H. simpl. reflexivity.
		+ simpl. reflexivity.
Qed.


(*
Пробуем таким же способом доказать другую теорему
*)
Definition func1(a b: bool): bool :=
match a, b with
	| true,  true  => false
	| true,  false => false
	| false, true  => true
	| false, false => false
end.


Theorem func1_true_elim2 : forall b c : bool,
  func1 b c = true -> c = true.
Proof.
	intros b c.
	intros H.
	destruct b as [] eqn:E.
	* destruct c as [] eqn:F.
		+ simpl. reflexivity.
		+ rewrite <- H. simpl. reflexivity.
	* destruct c as [] eqn:F.
		+ rewrite <- H. simpl. reflexivity.
		+ rewrite <- H. simpl. reflexivity.
Qed.

(*
Удалось доказать и её

Почему это работает?
Если func1 b c = true -> c = true , то в классической логике верно и 
c = false -> func1 b c = false
На этом, похоже, и выезжает движок

Забавно, что такая аксиома явно здесь не применяется, но, по сути,
неявно отрабатывается движком тактикой rewrite <- H
Т.к. там, где c == false условие теоремы тоже false и равенство H снова получается

Вообще говоря, это довольно противоречиво, т.к., очевидно,
что подставляя на место true наше условие теоремы,
мы создаём не тождество, кто сказал, что оно обязано выполняться при нарушении условия теоремы?
Что, если используемая аксиома не работает?

Если аксиома не работает, то, логично, мы всё равно не докажем чего-то такого, чего не должны доказать. Т.к. условие теоремы работает как тождество там, где должно, а в остальных случаях будет работать "случайно" или не работать: то есть доказать что-либо может не получится, но то, что не должно быть доказано, не докажется.


И как думать так, чтобы rewrite <- H использовать таким образом шаблонно?
*)
