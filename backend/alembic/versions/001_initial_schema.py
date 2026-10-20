"""initial schema

Revision ID: 001_initial_schema
Revises: 
Create Date: 2026-10-17 12:00:00.000000

"""
import sqlalchemy as sa

from alembic import op

revision = "001_initial_schema"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "cars",
        sa.Column("id", sa.String(length=50), nullable=False),
        sa.Column("vin", sa.String(length=50), nullable=False),
        sa.Column("make", sa.String(length=50), nullable=False),
        sa.Column("model", sa.String(length=50), nullable=False),
        sa.Column("year", sa.Integer(), nullable=False),
        sa.Column("license_plate", sa.String(length=20), nullable=False),
        sa.Column("engine_desc", sa.String(length=100), nullable=False),
        sa.Column("odometer_km", sa.Integer(), nullable=True),
        sa.Column("is_paired", sa.Boolean(), nullable=True),
        sa.Column("paired_at", sa.DateTime(), nullable=True),
        sa.Column("dongle_mac", sa.String(length=50), nullable=True),
        sa.Column("current_health_score", sa.Integer(), nullable=True),
        sa.Column("current_status", sa.String(length=20), nullable=True),
        sa.Column("urgent_prediction", sa.String(length=255), nullable=True),
        sa.Column("active_scenario", sa.String(length=50), nullable=True),
        sa.Column("simulated_day", sa.Float(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("vin")
    )
    op.create_index(op.f("ix_cars_id"), "cars", ["id"], unique=False)

    op.create_table(
        "garages",
        sa.Column("id", sa.String(length=50), nullable=False),
        sa.Column("name", sa.String(length=150), nullable=False),
        sa.Column("address", sa.String(length=255), nullable=False),
        sa.Column("distance_km", sa.Float(), nullable=False),
        sa.Column("rating", sa.Float(), nullable=True),
        sa.Column("is_partner", sa.Boolean(), nullable=True),
        sa.Column("specializations", sa.String(length=255), nullable=True),
        sa.Column("phone", sa.String(length=20), nullable=True),
        sa.PrimaryKeyConstraint("id")
    )

    op.create_table(
        "alerts",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("car_id", sa.String(length=50), nullable=False),
        sa.Column("title", sa.String(length=150), nullable=False),
        sa.Column("message", sa.Text(), nullable=False),
        sa.Column("severity", sa.String(length=20), nullable=False),
        sa.Column("component_name", sa.String(length=100), nullable=False),
        sa.Column("is_read", sa.Boolean(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(["car_id"], ["cars.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id")
    )
    op.create_index(op.f("ix_alerts_car_id"), "alerts", ["car_id"], unique=False)
    op.create_index(op.f("ix_alerts_created_at"), "alerts", ["created_at"], unique=False)

    op.create_table(
        "telemetry_records",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("car_id", sa.String(length=50), nullable=False),
        sa.Column("timestamp", sa.DateTime(), nullable=False),
        sa.Column("rpm", sa.Float(), nullable=False),
        sa.Column("speed", sa.Float(), nullable=False),
        sa.Column("coolant_temp", sa.Float(), nullable=False),
        sa.Column("engine_load", sa.Float(), nullable=False),
        sa.Column("battery_voltage", sa.Float(), nullable=False),
        sa.Column("intake_air_temp", sa.Float(), nullable=False),
        sa.Column("short_fuel_trim", sa.Float(), nullable=False),
        sa.Column("long_fuel_trim", sa.Float(), nullable=False),
        sa.Column("maf", sa.Float(), nullable=False),
        sa.Column("throttle_pos", sa.Float(), nullable=False),
        sa.Column("o2_voltage", sa.Float(), nullable=False),
        sa.Column("engine_on", sa.Boolean(), nullable=True),
        sa.Column("simulated_day", sa.Float(), nullable=True),
        sa.ForeignKeyConstraint(["car_id"], ["cars.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id")
    )
    op.create_index("ix_telemetry_car_timestamp", "telemetry_records", ["car_id", "timestamp"], unique=False)
    op.create_index(op.f("ix_telemetry_records_car_id"), "telemetry_records", ["car_id"], unique=False)
    op.create_index(op.f("ix_telemetry_records_timestamp"), "telemetry_records", ["timestamp"], unique=False)

    op.create_table(
        "service_bookings",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("car_id", sa.String(length=50), nullable=False),
        sa.Column("garage_id", sa.String(length=50), nullable=False),
        sa.Column("service_type", sa.String(length=100), nullable=False),
        sa.Column("scheduled_slot", sa.String(length=100), nullable=False),
        sa.Column("status", sa.String(length=50), nullable=True),
        sa.Column("estimated_cost_inr", sa.Integer(), nullable=True),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(["car_id"], ["cars.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["garage_id"], ["garages.id"]),
        sa.PrimaryKeyConstraint("id")
    )
    op.create_index(op.f("ix_service_bookings_car_id"), "service_bookings", ["car_id"], unique=False)


def downgrade() -> None:
    op.drop_table("service_bookings")
    op.drop_table("telemetry_records")
    op.drop_table("alerts")
    op.drop_table("garages")
    op.drop_table("cars")
