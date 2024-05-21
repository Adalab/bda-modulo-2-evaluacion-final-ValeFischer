USE sakila; #especificamos la BBDD que usaremos

/*1. Selecciona todos los nombres de las películas sin que aparezcan duplicados.*/
SELECT DISTINCT title
FROM film;

/*2. Muestra los nombres de todas las películas que tengan una clasificación de "PG-13".*/
SELECT *  #revisamos esta tabla para confirmar si es la que necesitamos usar
FROM film
LIMIT 10;

SELECT *
FROM film
WHERE rating = "PG-13";

/*3. Encuentra el título y la descripción de todas las películas que contengan la palabra
"amazing" en su descripción.*/

SELECT title, description
FROM film
WHERE description LIKE '%amazing%';

/*4. Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.*/
SELECT title
FROM film
WHERE length = 120;

/*5. Recupera los nombres de todos los actores.*/
SELECT first_name
FROM actor;

/*6. Encuentra el nombre y apellido de los actores que tengan "Gibson" en su apellido.*/
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%Gibson%';

SELECT first_name, last_name
FROM actor
WHERE last_name = "Gibson";

/*probamos estas dos formas de realizar la consulta, donde la primera consulta (LIKE '%Gibson%'),
busca cualquier registro que contenga 'Gibson' en alguna parte del apellido, 
mientras que la segunda consulta (= "Gibson") busca una coincidencia exacta.*/

/*7. Encuentra los nombres de los actores que tengan un actor_id entre 10 y 20.*/

SELECT first_name
FROM actor
WHERE actor_id BETWEEN 10 AND 20;

SELECT first_name, last_name /*también podemos ver nombre y appellido*/
FROM actor
WHERE actor_id BETWEEN 10 AND 20;


/*8. Encuentra el título de las películas en la tabla film que no sean ni "R" ni "PG-13" en
cuanto a su clasificación.*/

SELECT title
FROM film
WHERE NOT rating = "R"  OR rating = "PG-13";

/*9. Encuentra la cantidad total de películas en cada clasificación de la tabla film y muestra la
clasificación junto con el recuento.*/

SELECT rating, COUNT(film_id) AS total_movies
FROM film
GROUP BY rating;


/*10. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del
cliente, su nombre y apellido junto con la cantidad de películas alquiladas.*/

SELECT customer.customer_id, customer.first_name, customer.last_name, COUNT(rental.rental_id) AS total_rentals
FROM customer
JOIN rental ON customer.customer_id = rental.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name;

/*11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de
la categoría junto con el recuento de alquileres.*/

SELECT 
    category.name,
    (
        SELECT COUNT(*)
        FROM film
        WHERE film.film_id IN (
            SELECT film_id
            FROM film_category
            WHERE category_id = category.category_id
        )
    ) AS total_rental
FROM 
    category
ORDER BY 
    total_rental DESC;

/*12. Encuentra el promedio de duración de las películas para cada clasificación de la tabla
film y muestra la clasificación junto con el promedio de duración.*/

SELECT rating, AVG(length) AS length_avg
FROM film
GROUP BY rating;

/*13. Encuentra el nombre y apellido de los actores que aparecen en la película con title "Indian
Love".*/

SELECT first_name, last_name
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
JOIN film ON film_actor.film_id = film.film_id
WHERE film.title = 'Indian Love';

/*14. Muestra el título de todas las películas que contengan la palabra "dog" o "cat" en su
descripción.*/

SELECT title
FROM film
WHERE description LIKE '%dog%' OR '%cat%';

/*15. Hay algún actor o actriz que no apareca en ninguna película en la tabla film_actor.*/

SELECT first_name, last_name
FROM actor
WHERE actor_id NOT IN (SELECT actor_id FROM film_actor);

SELECT actor_id #también podemos hacerlo por actor_id
FROM actor
WHERE actor_id NOT IN (SELECT actor_id FROM film_actor);

#vemos que hay 0(es decir, no hay) actor o actriz que no aparezca en niguna película.
#ver si hacer con left join

/*16. Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010.*/

SELECT title
FROM film
WHERE release_year BETWEEN 2005 AND 2010;

/*17. Encuentra el título de todas las películas que son de la misma categoría que "Family".*/

SELECT title
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
WHERE category.name = 'Family';

/*18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.*/

SELECT first_name, last_name
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
GROUP BY actor.actor_id
HAVING COUNT(film_actor.film_id) > 10;

/*19. Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 2
horas en la tabla film.*/

SELECT length #vemos algunos registros de lengh para ver su formato. Confirmamos que esta en minutos.
FROM film
LIMIT 50;

SELECT title
FROM film
WHERE rating = 'R' AND length > 120;

/*20. Encuentra las categorías de películas que tienen un promedio de duración superior a 120
minutos y muestra el nombre de la categoría junto con el promedio de duración.*/

SELECT category.name AS category_name, AVG(film.length) AS length_avg
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN film ON film_category.film_id = film.film_id
GROUP BY category.category_id
HAVING AVG(film.length) > 120;

/*21. Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre del
actor junto con la cantidad de películas en las que han actuado.*/

SELECT actor.first_name AS actor_name, COUNT(*) AS movies
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
GROUP BY actor.actor_id
HAVING movies > 5;

/*22. Encuentra el título de todas las películas que fueron alquiladas por más de 5 días. Utiliza
una subconsulta para encontrar los rental_ids con una duración superior a 5 días y luego
selecciona las películas correspondientes.*/

SELECT DISTINCT film.title
FROM film 
JOIN inventory ON film.film_id = inventory.film_id
WHERE inventory.inventory_id IN (
    SELECT rental.inventory_id
    FROM rental 
    WHERE DATEDIFF(rental.return_date, rental.rental_date) > 5
    );

#probamos también con la columnda rental_duration de la tabla Film
    SELECT DISTINCT film.title
FROM film 
JOIN inventory ON film.film_id = inventory.film_id
WHERE inventory.inventory_id IN (
    SELECT rental.inventory_id
    FROM rental 
    WHERE film.rental_duration > 5
    );

/*23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de
la categoría "Horror". Utiliza una subconsulta para encontrar los actores que han actuado
en películas de la categoría "Horror" y luego exclúyelos de la lista de actores.*/

SELECT first_name, last_name
FROM actor
WHERE actor_id NOT IN (
    SELECT DISTINCT film_actor.actor_id
    FROM film_actor
    JOIN film_category ON film_actor.film_id = film_category.film_id
    JOIN category  ON film_category.category_id = category.category_id
    WHERE category.name = 'Horror'
);

#BONUS
/*24. BONUS: Encuentra el título de las películas que son comedias y tienen una duración mayor
a 180 minutos en la tabla film.*/

SELECT title
FROM film
WHERE length > 180
AND film_id IN (
	SELECT film_id
	FROM film_category 
    WHERE category_id = (
		SELECT category_id
        from category
        WHERE name = 'Comedy')
);
			
/*25. BONUS: Encuentra todos los actores que han actuado juntos en al menos una película. La
consulta debe mostrar el nombre y apellido de los actores y el número de películas en las
que han actuado juntos.*/
SELECT *   #revisamos como se ve la tabla film_actor
FROM film_actor;

SELECT a1.first_name AS first_name_1, a1.last_name AS last_name_1,
       a2.first_name AS first_name_2, a2.last_name AS last_name_2,
       COUNT(*) AS movies_together
FROM film_actor fa1
JOIN film_actor fa2 ON fa1.film_id = fa2.film_id AND fa1.actor_id < fa2.actor_id
JOIN actor a1 ON fa1.actor_id = a1.actor_id
JOIN actor a2 ON fa2.actor_id = a2.actor_id
GROUP BY a1.actor_id, a1.first_name, a1.last_name, a2.actor_id, a2.first_name, a2.last_name
HAVING COUNT(*) >= 1;

