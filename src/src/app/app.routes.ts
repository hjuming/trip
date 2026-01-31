import { Routes } from '@angular/router';

import { AuthComponent } from './components/auth/auth.component';

import { DashboardComponent } from './components/dashboard/dashboard.component';
import { AuthGuard } from './services/auth.guard';
import { TripComponent } from './components/trip/trip.component';
import { TripsComponent } from './components/trips/trips.component';
import { SharedTripComponent } from './components/shared-trip/shared-trip.component';

export const routes: Routes = [
  {
    path: 'auth',
    pathMatch: 'full',
    component: AuthComponent,
    title: 'TRIP - Authentication',
  },

  {
    path: 's',
    children: [
      {
        path: 't/:token',
        component: SharedTripComponent,
        title: 'TRIP - Shared Trip',
      },

      { path: '**', redirectTo: '/home', pathMatch: 'full' },
    ],
  },

  {
    path: '',
    // canActivate: [AuthGuard],  // 暫時註解掉驗證
    children: [
      {
        path: '',
        redirectTo: '/home',
        pathMatch: 'full',
      },
      {
        path: 'home',
        component: DashboardComponent,
        title: 'TRIP - 地圖',
      },
      {
        path: 'trips',
        children: [
          {
            path: '',
            component: TripsComponent,
            title: 'TRIP - 行程',
          },
          {
            path: ':id',
            component: TripComponent,
            title: 'TRIP - 行程詳情',
          },
        ],
      },

      { path: '**', redirectTo: '/home', pathMatch: 'full' },
    ],
  },

  { path: '**', redirectTo: '/', pathMatch: 'full' },
];
