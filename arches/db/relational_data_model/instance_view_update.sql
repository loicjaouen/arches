create or replace function __arches_instance_view_update() returns trigger as $$
    declare
        view_namespace text;
        model_id uuid;
        instance_id uuid;
        transaction_id uuid;
        edit_type text;
    begin
        view_namespace = format('%s.%s', tg_table_schema, tg_table_name);
        select obj_description(view_namespace::regclass, 'pg_class') into model_id;
        if (TG_OP = 'DELETE') then
            delete from public.resource_instances where resourceinstanceid = old.resourceinstanceid;
            insert into edit_log (
                resourceclassid,
                resourceinstanceid,
                edittype,
                timestamp,
                note,
                transactionid
            ) values (
                model_id,
                old.resourceinstanceid,
                'delete',
                now(),
                'loaded via SQL backend',
                public.uuid_generate_v1mc()
            );
            return old;
        else
            instance_id = new.resourceinstanceid;
            if instance_id is null then
                instance_id = public.uuid_generate_v1mc();
            end if;

            if (new.transactionid is null) then
                transaction_id = public.uuid_generate_v1mc();
            else
                transaction_id = new.transactionid;
            end if;

            if (TG_OP = 'UPDATE') then
                edit_type = 'edit';
                if (transaction_id = old.transactionid) then
                    transaction_id = public.uuid_generate_v1mc();
                end if;
                update public.resource_instances
                set createdtime = new.createdtime,
                    legacyid = new.legacyid
                where resourceinstanceid = instance_id;
            elsif (TG_OP = 'INSERT') then
                edit_type = 'create';
                insert into public.resource_instances(
                    resourceinstanceid,
                    graphid,
                    legacyid,
                    createdtime
                ) values (
                    instance_id,
                    model_id,
                    new.legacyid,
                    now()
                );
                raise notice 'instance "%" created.', instance_id;
            end if;
            insert into edit_log (
                resourceclassid,
                resourceinstanceid,
                edittype,
                timestamp,
                note,
                transactionid
            ) values (
                model_id,
                instance_id,
                edit_type,
                now(),
                'loaded via SQL backend',
                transaction_id
            );
            return new;
        end if;
    end;
$$ language plpgsql;