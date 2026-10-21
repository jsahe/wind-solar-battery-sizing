# Data

| File | Contents | Source | Included |
|---|---|---|---|
| `west-lafayette-2020-wind.csv` | 5-minute wind speed at 80, 100 and 120 m, West Lafayette, IN, 2020 | NREL Wind Resource Database, [wrdb.nrel.gov](https://wrdb.nrel.gov/data-viewer) | Yes |
| `west-lafayette-2020-solar.csv` | Hourly temperature and global, direct-normal and diffuse irradiance, 2020 | [OikoLab](https://oikolab.com) (ERA5-based) | **No**, see below |

## Getting the solar file

OikoLab data is subject to OikoLab's terms, so it is not redistributed here. To recreate the file:

1. Request hourly data for **40.4259 N, 86.9081 W**, 2020-01-01 to 2020-12-31, UTC.
2. Variables, in this column order after the metadata columns:
   `temperature (degC)`, `surface_solar_radiation (W/m^2)`,
   `direct_normal_solar_radiation (W/m^2)`, `surface_diffuse_solar_radiation (W/m^2)`.
3. Save it here as `west-lafayette-2020-solar.csv`.

The expected header is:

```
datetime (UTC),"coordinates (lat,lon)",model (name),model elevation (surface),utc_offset (hrs),temperature (degC),surface_solar_radiation (W/m^2),direct_normal_solar_radiation (W/m^2),surface_diffuse_solar_radiation (W/m^2)
```

Any hourly irradiance source with the same columns will work with `src/importWeather.m`.
