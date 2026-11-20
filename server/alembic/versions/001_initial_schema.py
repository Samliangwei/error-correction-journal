"""Initial schema

Revision ID: 001
Revises: 
Create Date: 2024-11-20 07:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = '001'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'error_questions',
        sa.Column('id', sa.String(36), primary_key=True),
        sa.Column('subject', sa.String(50), nullable=False),
        sa.Column('question', sa.Text, nullable=False),
        sa.Column('my_answer', sa.Text, nullable=False),
        sa.Column('correct_answer', sa.Text, nullable=False),
        sa.Column('reason', sa.Text, nullable=False),
        sa.Column('mastery_status', sa.Enum('not_mastered', 'partially_mastered', 'mastered', name='masterystatus'), nullable=False),
        sa.Column('created_at', sa.DateTime, nullable=False),
        sa.Column('updated_at', sa.DateTime, nullable=False),
        sa.Column('deleted_at', sa.DateTime, nullable=True),
        sa.Column('last_synced_at', sa.DateTime, nullable=True),
        sa.Column('user_id', sa.String(36), nullable=False, server_default='default'),
    )
    
    op.create_index('ix_error_questions_subject', 'error_questions', ['subject'])
    op.create_index('ix_error_questions_mastery_status', 'error_questions', ['mastery_status'])
    op.create_index('ix_error_questions_deleted_at', 'error_questions', ['deleted_at'])
    op.create_index('ix_error_questions_user_id', 'error_questions', ['user_id'])


def downgrade() -> None:
    op.drop_index('ix_error_questions_user_id', 'error_questions')
    op.drop_index('ix_error_questions_deleted_at', 'error_questions')
    op.drop_index('ix_error_questions_mastery_status', 'error_questions')
    op.drop_index('ix_error_questions_subject', 'error_questions')
    op.drop_table('error_questions')
