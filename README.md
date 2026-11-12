# WB Shop — Flutter client for the Django `online_store` backend

Educational project: a Wildberries-style shop for **Android and iOS**.
State management: **BLoC** (`flutter_bloc`). Code is commented to be read top to bottom.

## Features
- Login / registration (JWT), session saved on the phone, auto logout on 401
- Home: search (name / article), categories, sorting, "Original only" filter, infinite scroll
- Category page with sub category chips
- Product page: image slider, description, reviews, add to cart / quantity stepper
- Cart: change quantity, swipe to delete, total price
- Profile + logout

## Run
1. Start the backend so phones/emulators can reach it:
   `python manage.py runserver 0.0.0.0:8000`
2. `flutter pub get && flutter run`
3. Server address is in `lib/core/constants.dart`
   (Android emulator `10.0.2.2`, iOS simulator `127.0.0.1`, real device = your computer's LAN IP).

## Project structure (read in this order)
```
lib/
  main.dart            creates objects, decides Login vs Main screen
  core/                config, theme, Dio client, token storage
  models/              JSON -> Dart classes
  repositories/        the ONLY place that talks to the API
  blocs/               one file per bloc: events + state + bloc
  screens/             full pages
  widgets/             small reusable pieces
```
Flow: `Screen --event--> Bloc --calls--> Repository --HTTP--> Django`, then `Bloc --state--> Screen`.

## Backend notes (backend was NOT modified)
| Problem | Effect | Suggested fix in Django |
|---|---|---|
| `CartSerializer.get_total_price` calls `obj.get_total_price()`, but `Cart` only has `get_final_price()` | `GET /cart/` returns 500. The app uses `/cart_items/` and sums the total itself | call `obj.get_final_price()` |
| Access token lives 5 min and there is no `token/refresh/` route | User must log in again every 5 minutes | add `path('token/refresh/', TokenRefreshView.as_view())` and raise `ACCESS_TOKEN_LIFETIME` |
| `CategoryDetailSerializer` returns sub category names without ids | App matches names with `/sub_category/` | add `id` to `SubCategorySerializer` |
| `ReviewSerializer` has no `product` field and a read-only nested `user`; `ReviewViewSet` has no permissions | Reviews can't be created from the app (display only) | add `product` field, set `user=request.user` in `perform_create` |
| `ProductListAPIView` requires auth, `PAGE_SIZE = 2` | App always sends `?limit=` | — |
| `LogoutView` needs `rest_framework_simplejwt.token_blacklist` in `INSTALLED_APPS` | Logout request may fail; app logs out locally anyway | add the app + migrate |
| No orders API | "Checkout" button is a stub | add Order model/endpoints |
