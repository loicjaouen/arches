# Generated by Django 2.2.8 on 2020-03-04 15:48

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('models', '5881_fileviewer'),
    ]

    operations = [
        migrations.RenameField(
            model_name='mobilesynclog',
            old_name='user',
            new_name='userid',
        ),
        migrations.RemoveField(
            model_name='mobilesynclog',
            name='resourcescreated',
        ),
        migrations.RemoveField(
            model_name='mobilesynclog',
            name='tilescreated',
        ),
        migrations.RemoveField(
            model_name='mobilesynclog',
            name='tilesdeleted',
        ),
        migrations.RemoveField(
            model_name='mobilesynclog',
            name='tilesupdated',
        ),
    ]
