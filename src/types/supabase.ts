export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      backoffice_operations: {
        Row: {
          event_id: string
          metadata: Json | null
          operation_time: string
          operation_type: Database["public"]["Enums"]["operation_type"]
          user_id: string | null
        }
        Insert: {
          event_id?: string
          metadata?: Json | null
          operation_time?: string
          operation_type: Database["public"]["Enums"]["operation_type"]
          user_id?: string | null
        }
        Update: {
          event_id?: string
          metadata?: Json | null
          operation_time?: string
          operation_type?: Database["public"]["Enums"]["operation_type"]
          user_id?: string | null
        }
        Relationships: []
      }
      brickshare_pudo_locations: {
        Row: {
          address: string
          city: string
          contact_email: string | null
          contact_phone: string | null
          created_at: string | null
          id: string
          is_active: boolean | null
          latitude: number | null
          longitude: number | null
          name: string
          notes: string | null
          opening_hours: Json | null
          postal_code: string
          province: string
          updated_at: string | null
        }
        Insert: {
          address: string
          city: string
          contact_email?: string | null
          contact_phone?: string | null
          created_at?: string | null
          id: string
          is_active?: boolean | null
          latitude?: number | null
          longitude?: number | null
          name: string
          notes?: string | null
          opening_hours?: Json | null
          postal_code: string
          province: string
          updated_at?: string | null
        }
        Update: {
          address?: string
          city?: string
          contact_email?: string | null
          contact_phone?: string | null
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          latitude?: number | null
          longitude?: number | null
          name?: string
          notes?: string | null
          opening_hours?: Json | null
          postal_code?: string
          province?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      donations: {
        Row: {
          co2_evitado: number
          created_at: string
          direccion: string | null
          email: string
          id: string
          metodo_entrega: string
          ninos_beneficiados: number
          nombre: string
          peso_estimado: number
          recompensa: string
          status: string
          telefono: string | null
          tracking_code: string | null
          updated_at: string
          user_id: string | null
        }
        Insert: {
          co2_evitado: number
          created_at?: string
          direccion?: string | null
          email: string
          id?: string
          metodo_entrega: string
          ninos_beneficiados: number
          nombre: string
          peso_estimado: number
          recompensa: string
          status?: string
          telefono?: string | null
          tracking_code?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          co2_evitado?: number
          created_at?: string
          direccion?: string | null
          email?: string
          id?: string
          metodo_entrega?: string
          ninos_beneficiados?: number
          nombre?: string
          peso_estimado?: number
          recompensa?: string
          status?: string
          telefono?: string | null
          tracking_code?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Relationships: []
      }
      shipments: {
        Row: {
          brickshare_metadata: Json | null
          brickshare_package_id: string | null
          brickshare_pudo_id: string | null
          shipping_city: string
          shipping_postal_code: string
          correos_shipment_id: string | null
          created_at: string
          delivery_qr_code: string | null
          delivery_qr_expires_at: string | null
          delivery_validated_at: string | null
          shipping_address: string
          pickup_provider_address: string | null
          shipment_status: string
          handling_status: boolean | null
          assigned_date: string | null
          estimated_return_date: string | null
          delivery_date: string | null
          actual_delivery_date: string | null
          user_delivery_date: string | null
          warehouse_reception_date: string | null
          warehouse_pickup_date: string | null
          return_request_date: string | null
          id: string
          label_url: string | null
          last_tracking_update: string | null
          additional_notes: string | null
          tracking_number: string | null
          shipping_country: string
          pickup_id: string | null
          pickup_type: string | null
          shipping_provider: string | null
          pickup_provider: string | null
          return_qr_code: string | null
          return_qr_expires_at: string | null
          return_validated_at: string | null
          set_id: string | null
          set_ref: string | null
          swikly_deposit_amount: number | null
          swikly_status: string | null
          swikly_wish_id: string | null
          swikly_wish_url: string | null
          carrier: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          brickshare_metadata?: Json | null
          brickshare_package_id?: string | null
          brickshare_pudo_id?: string | null
          shipping_city: string
          shipping_postal_code: string
          correos_shipment_id?: string | null
          created_at?: string
          delivery_qr_code?: string | null
          delivery_qr_expires_at?: string | null
          delivery_validated_at?: string | null
          shipping_address: string
          pickup_provider_address?: string | null
          shipment_status?: string
          handling_status?: boolean | null
          assigned_date?: string | null
          estimated_return_date?: string | null
          delivery_date?: string | null
          actual_delivery_date?: string | null
          user_delivery_date?: string | null
          warehouse_reception_date?: string | null
          warehouse_pickup_date?: string | null
          return_request_date?: string | null
          id?: string
          label_url?: string | null
          last_tracking_update?: string | null
          additional_notes?: string | null
          tracking_number?: string | null
          shipping_country?: string
          pickup_id?: string | null
          pickup_type?: string | null
          shipping_provider?: string | null
          pickup_provider?: string | null
          return_qr_code?: string | null
          return_qr_expires_at?: string | null
          return_validated_at?: string | null
          set_id?: string | null
          set_ref?: string | null
          swikly_deposit_amount?: number | null
          swikly_status?: string | null
          swikly_wish_id?: string | null
          swikly_wish_url?: string | null
          carrier?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          brickshare_metadata?: Json | null
          brickshare_package_id?: string | null
          brickshare_pudo_id?: string | null
          shipping_city?: string
          shipping_postal_code?: string
          correos_shipment_id?: string | null
          created_at?: string
          delivery_qr_code?: string | null
          delivery_qr_expires_at?: string | null
          delivery_validated_at?: string | null
          shipping_address?: string
          pickup_provider_address?: string | null
          shipment_status?: string
          handling_status?: boolean | null
          assigned_date?: string | null
          estimated_return_date?: string | null
          delivery_date?: string | null
          actual_delivery_date?: string | null
          user_delivery_date?: string | null
          warehouse_reception_date?: string | null
          warehouse_pickup_date?: string | null
          return_request_date?: string | null
          id?: string
          label_url?: string | null
          last_tracking_update?: string | null
          additional_notes?: string | null
          tracking_number?: string | null
          shipping_country?: string
          pickup_id?: string | null
          pickup_type?: string | null
          shipping_provider?: string | null
          pickup_provider?: string | null
          return_qr_code?: string | null
          return_qr_expires_at?: string | null
          return_validated_at?: string | null
          set_id?: string | null
          set_ref?: string | null
          swikly_deposit_amount?: number | null
          swikly_status?: string | null
          swikly_wish_id?: string | null
          swikly_wish_url?: string | null
          carrier?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "shipments_set_id_fkey"
            columns: ["set_id"]
            isOneToOne: false
            referencedRelation: "sets"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "shipments_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
        ]
      }
      inventory_sets: {
        Row: {
          created_at: string
          in_return: number
          in_shipping: number
          in_repair: number
          in_use: number
          id: string
          inventory_set_total_qty: number
          set_id: string
          set_ref: string | null
          spare_parts_order: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          in_return?: number
          in_shipping?: number
          in_repair?: number
          in_use?: number
          id?: string
          inventory_set_total_qty?: number
          set_id: string
          set_ref?: string | null
          spare_parts_order?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          in_return?: number
          in_shipping?: number
          in_repair?: number
          in_use?: number
          id?: string
          inventory_set_total_qty?: number
          set_id?: string
          set_ref?: string | null
          spare_parts_order?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "inventario_sets_set_id_fkey"
            columns: ["set_id"]
            isOneToOne: true
            referencedRelation: "sets"
            referencedColumns: ["id"]
          },
        ]
      }
      reception_operations: {
        Row: {
          created_at: string
          event_id: string | null
          id: string
          missing_parts: string | null
          set_id: string
          reception_status: boolean
          updated_at: string
          user_id: string
          weight_measured: number | null
        }
        Insert: {
          created_at?: string
          event_id?: string | null
          id?: string
          missing_parts?: string | null
          set_id: string
          reception_status?: boolean
          updated_at?: string
          user_id: string
          weight_measured?: number | null
        }
        Update: {
          created_at?: string
          event_id?: string | null
          id?: string
          missing_parts?: string | null
          set_id?: string
          reception_status?: boolean
          updated_at?: string
          user_id?: string
          weight_measured?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "reception_operations_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "brickshare_pudo_shipments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reception_operations_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "shipments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reception_operations_set_id_fkey"
            columns: ["set_id"]
            isOneToOne: false
            referencedRelation: "sets"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          avatar_url: string | null
          created_at: string
          full_name: string | null
          id: string
          impact_points: number | null
          referral_code: string | null
          referral_credits: number
          referred_by: string | null
          sub_status: string | null
          updated_at: string
        }
        Insert: {
          avatar_url?: string | null
          created_at?: string
          full_name?: string | null
          id: string
          impact_points?: number | null
          referral_code?: string | null
          referral_credits?: number
          referred_by?: string | null
          sub_status?: string | null
          updated_at?: string
        }
        Update: {
          avatar_url?: string | null
          created_at?: string
          full_name?: string | null
          id?: string
          impact_points?: number | null
          referral_code?: string | null
          referral_credits?: number
          referred_by?: string | null
          sub_status?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      qr_validation_logs: {
        Row: {
          created_at: string | null
          id: string
          metadata: Json | null
          qr_code: string
          shipment_id: string
          validated_at: string | null
          validated_by: string | null
          validation_status: string
          validation_type: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          metadata?: Json | null
          qr_code: string
          shipment_id: string
          validated_at?: string | null
          validated_by?: string | null
          validation_status: string
          validation_type: string
        }
        Update: {
          created_at?: string | null
          id?: string
          metadata?: Json | null
          qr_code?: string
          shipment_id?: string
          validated_at?: string | null
          validated_by?: string | null
          validation_status?: string
          validation_type?: string
        }
        Relationships: [
          {
            foreignKeyName: "qr_validation_logs_shipment_id_fkey"
            columns: ["shipment_id"]
            isOneToOne: false
            referencedRelation: "brickshare_pudo_shipments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "qr_validation_logs_shipment_id_fkey"
            columns: ["shipment_id"]
            isOneToOne: false
            referencedRelation: "shipments"
            referencedColumns: ["id"]
          },
        ]
      }
      referrals: {
        Row: {
          created_at: string
          credited_at: string | null
          id: string
          referee_id: string
          referrer_id: string
          reward_credits: number
          status: string
          stripe_coupon_id: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          credited_at?: string | null
          id?: string
          referee_id: string
          referrer_id: string
          reward_credits?: number
          status?: string
          stripe_coupon_id?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          credited_at?: string | null
          id?: string
          referee_id?: string
          referrer_id?: string
          reward_credits?: number
          status?: string
          stripe_coupon_id?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      reviews: {
        Row: {
          age_fit: boolean | null
          comment: string | null
          created_at: string
          difficulty: number | null
          shipment_id: string | null
          id: string
          is_published: boolean
          rating: number
          set_id: string
          updated_at: string
          user_id: string
          would_reorder: boolean | null
        }
        Insert: {
          age_fit?: boolean | null
          comment?: string | null
          created_at?: string
          difficulty?: number | null
          shipment_id?: string | null
          id?: string
          is_published?: boolean
          rating: number
          set_id: string
          updated_at?: string
          user_id: string
          would_reorder?: boolean | null
        }
        Update: {
          age_fit?: boolean | null
          comment?: string | null
          created_at?: string
          difficulty?: number | null
          shipment_id?: string | null
          id?: string
          is_published?: boolean
          rating?: number
          set_id?: string
          updated_at?: string
          user_id?: string
          would_reorder?: boolean | null
        }
        Relationships: [
          {
            foreignKeyName: "reviews_shipment_id_fkey"
            columns: ["shipment_id"]
            isOneToOne: false
            referencedRelation: "brickshare_pudo_shipments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reviews_shipment_id_fkey"
            columns: ["shipment_id"]
            isOneToOne: false
            referencedRelation: "shipments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reviews_set_id_fkey"
            columns: ["set_id"]
            isOneToOne: false
            referencedRelation: "sets"
            referencedColumns: ["id"]
          },
        ]
      }
      set_piece_list: {
        Row: {
          color_id: number | null
          color_ref: string | null
          created_at: string
          element_id: string | null
          external_ids: Json | null
          id: string
          is_spare: boolean | null
          is_trans: boolean | null
          part_cat_id: number | null
          piece_description: string | null
          piece_image_url: string | null
          piece_qty: number
          piece_ref: string
          piece_studdim: string | null
          piece_weight: number | null
          set_id: string
          set_ref: string
          updated_at: string
          year_from: number | null
          year_to: number | null
        }
        Insert: {
          color_id?: number | null
          color_ref?: string | null
          created_at?: string
          element_id?: string | null
          external_ids?: Json | null
          id?: string
          is_spare?: boolean | null
          is_trans?: boolean | null
          part_cat_id?: number | null
          piece_description?: string | null
          piece_image_url?: string | null
          piece_qty?: number
          piece_ref: string
          piece_studdim?: string | null
          piece_weight?: number | null
          set_id: string
          set_ref: string
          updated_at?: string
          year_from?: number | null
          year_to?: number | null
        }
        Update: {
          color_id?: number | null
          color_ref?: string | null
          created_at?: string
          element_id?: string | null
          external_ids?: Json | null
          id?: string
          is_spare?: boolean | null
          is_trans?: boolean | null
          part_cat_id?: number | null
          piece_description?: string | null
          piece_image_url?: string | null
          piece_qty?: number
          piece_ref?: string
          piece_studdim?: string | null
          piece_weight?: number | null
          set_id?: string
          set_ref?: string
          updated_at?: string
          year_from?: number | null
          year_to?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "set_piece_list_set_id_fkey"
            columns: ["set_id"]
            isOneToOne: false
            referencedRelation: "sets"
            referencedColumns: ["id"]
          },
        ]
      }
      sets: {
        Row: {
          barcode_ean: string | null
          barcode_upc: string | null
          catalogue_visibility: boolean
          created_at: string
          current_value_new: number | null
          current_value_used: number | null
          id: string
          set_age_range: string
          set_description: string | null
          set_image_url: string | null
          set_minifigs: number | null
          set_name: string
          set_piece_count: number
          set_price: number | null
          set_pvp_release: number | null
          set_ref: string | null
          set_status: string | null
          set_subtheme: string | null
          set_theme: string
          set_weight: number | null
          skill_boost: string[] | null
          updated_at: string
          year_released: number | null
        }
        Insert: {
          barcode_ean?: string | null
          barcode_upc?: string | null
          catalogue_visibility?: boolean
          created_at?: string
          current_value_new?: number | null
          current_value_used?: number | null
          id?: string
          set_age_range: string
          set_description?: string | null
          set_image_url?: string | null
          set_minifigs?: number | null
          set_name: string
          set_piece_count: number
          set_price?: number | null
          set_pvp_release?: number | null
          set_ref?: string | null
          set_status?: string | null
          set_subtheme?: string | null
          set_theme: string
          set_weight?: number | null
          skill_boost?: string[] | null
          updated_at?: string
          year_released?: number | null
        }
        Update: {
          barcode_ean?: string | null
          barcode_upc?: string | null
          catalogue_visibility?: boolean
          created_at?: string
          current_value_new?: number | null
          current_value_used?: number | null
          id?: string
          set_age_range?: string
          set_description?: string | null
          set_image_url?: string | null
          set_minifigs?: number | null
          set_name?: string
          set_piece_count?: number
          set_price?: number | null
          set_pvp_release?: number | null
          set_ref?: string | null
          set_status?: string | null
          set_subtheme?: string | null
          set_theme?: string
          set_weight?: number | null
          skill_boost?: string[] | null
          updated_at?: string
          year_released?: number | null
        }
        Relationships: []
      }
      shipping_orders: {
        Row: {
          created_at: string | null
          id: string
          set_id: string
          shipping_order_date: string | null
          tracking_ref: string | null
          updated_at: string | null
          user_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          set_id: string
          shipping_order_date?: string | null
          tracking_ref?: string | null
          updated_at?: string | null
          user_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          set_id?: string
          shipping_order_date?: string | null
          tracking_ref?: string | null
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "shipping_orders_set_id_fkey"
            columns: ["set_id"]
            isOneToOne: false
            referencedRelation: "sets"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "shipping_orders_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
        ]
      }
      user_roles: {
        Row: {
          created_at: string
          id: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          user_id?: string
        }
        Relationships: []
      }
      users: {
        Row: {
          address: string | null
          address_extra: string | null
          avatar_url: string | null
          city: string | null
          created_at: string
          email: string | null
          full_name: string | null
          id: string
          impact_points: number | null
          phone: string | null
          profile_completed: boolean | null
          province: string | null
          stripe_customer_id: string | null
          subscription_status: string | null
          subscription_type: string | null
          updated_at: string
          user_id: string
          user_status: string | null
          zip_code: string | null
        }
        Insert: {
          address?: string | null
          address_extra?: string | null
          avatar_url?: string | null
          city?: string | null
          created_at?: string
          email?: string | null
          full_name?: string | null
          id?: string
          impact_points?: number | null
          phone?: string | null
          profile_completed?: boolean | null
          province?: string | null
          stripe_customer_id?: string | null
          subscription_status?: string | null
          subscription_type?: string | null
          updated_at?: string
          user_id: string
          user_status?: string | null
          zip_code?: string | null
        }
        Update: {
          address?: string | null
          address_extra?: string | null
          avatar_url?: string | null
          city?: string | null
          created_at?: string
          email?: string | null
          full_name?: string | null
          id?: string
          impact_points?: number | null
          phone?: string | null
          profile_completed?: boolean | null
          province?: string | null
          stripe_customer_id?: string | null
          subscription_status?: string | null
          subscription_type?: string | null
          updated_at?: string
          user_id?: string
          user_status?: string | null
          zip_code?: string | null
        }
        Relationships: []
      }
      users_correos_dropping: {
        Row: {
          correos_accessibility: boolean | null
          correos_locker_capacity: number | null
          correos_city: string
          correos_internal_code: string | null
          correos_zip_code: string
          correos_street: string
          correos_full_address: string
          correos_street_number: string | null
          correos_available: boolean
          correos_email: string | null
          correos_selection_date: string
          correos_opening_hours: string | null
          correos_structured_hours: Json | null
          correos_id_pudo: string
          correos_latitude: number
          correos_longitude: number
          correos_name: string
          correos_country: string
          correos_parking: boolean | null
          correos_province: string
          correos_additional_services: string[] | null
          correos_phone: string | null
          correos_point_type: string
          created_at: string
          updated_at: string
          user_id: string
        }
        Insert: {
          correos_accessibility?: boolean | null
          correos_locker_capacity?: number | null
          correos_city: string
          correos_internal_code?: string | null
          correos_zip_code: string
          correos_street: string
          correos_full_address: string
          correos_street_number?: string | null
          correos_available?: boolean
          correos_email?: string | null
          correos_selection_date?: string
          correos_opening_hours?: string | null
          correos_structured_hours?: Json | null
          correos_id_pudo: string
          correos_latitude: number
          correos_longitude: number
          correos_name: string
          correos_country?: string
          correos_parking?: boolean | null
          correos_province: string
          correos_additional_services?: string[] | null
          correos_phone?: string | null
          correos_point_type: string
          created_at?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          correos_accessibility?: boolean | null
          correos_locker_capacity?: number | null
          correos_city?: string
          correos_internal_code?: string | null
          correos_zip_code?: string
          correos_street?: string
          correos_full_address?: string
          correos_street_number?: string | null
          correos_available?: boolean
          correos_email?: string | null
          correos_selection_date?: string
          correos_opening_hours?: string | null
          correos_structured_hours?: Json | null
          correos_id_pudo?: string
          correos_latitude?: number
          correos_longitude?: number
          correos_name?: string
          correos_country?: string
          correos_parking?: boolean | null
          correos_province?: string
          correos_additional_services?: string[] | null
          correos_phone?: string | null
          correos_point_type?: string
          created_at?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "users_correos_dropping_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
        ]
      }
      wishlist: {
        Row: {
          created_at: string
          id: string
          set_id: string
          status: boolean
          status_changed_at: string | null
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          set_id: string
          status?: boolean
          status_changed_at?: string | null
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          set_id?: string
          status?: boolean
          status_changed_at?: string | null
          user_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      brickshare_pudo_shipments: {
        Row: {
          brickshare_package_id: string | null
          brickshare_pudo_id: string | null
          created_at: string | null
          delivery_qr_code: string | null
          delivery_qr_validated_at: string | null
          id: string | null
          pickup_type: string | null
          return_qr_code: string | null
          return_qr_validated_at: string | null
          status: string | null
          tracking_number: string | null
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          brickshare_package_id?: string | null
          brickshare_pudo_id?: string | null
          created_at?: string | null
          delivery_qr_code?: string | null
          delivery_qr_validated_at?: string | null
          id?: string | null
          pickup_type?: string | null
          return_qr_code?: string | null
          return_qr_validated_at?: string | null
          status?: string | null
          tracking_number?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          brickshare_package_id?: string | null
          brickshare_pudo_id?: string | null
          created_at?: string | null
          delivery_qr_code?: string | null
          delivery_qr_validated_at?: string | null
          id?: string | null
          pickup_type?: string | null
          return_qr_code?: string | null
          return_qr_validated_at?: string | null
          status?: string | null
          tracking_number?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "shipments_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
        ]
      }
      set_avg_ratings: {
        Row: {
          avg_rating: number | null
          review_count: number | null
          set_id: string | null
        }
        Relationships: [
          {
            foreignKeyName: "reviews_set_id_fkey"
            columns: ["set_id"]
            isOneToOne: false
            referencedRelation: "sets"
            referencedColumns: ["id"]
          },
        ]
      }
      set_review_stats: {
        Row: {
          avg_difficulty: number | null
          avg_rating: number | null
          five_stars: number | null
          four_stars: number | null
          one_star: number | null
          review_count: number | null
          set_id: string | null
          three_stars: number | null
          two_stars: number | null
          would_reorder_count: number | null
        }
        Relationships: [
          {
            foreignKeyName: "reviews_set_id_fkey"
            columns: ["set_id"]
            isOneToOne: false
            referencedRelation: "sets"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Functions: {
      assign_sets_to_users: {
        Args: never
        Returns: {
          created_at: string
          shipment_id: string
          order_id: string
          set_id: string
          set_name: string
          set_ref: string
          user_id: string
          user_name: string
        }[]
      }
      confirm_assign_sets_to_users: {
        Args: { p_user_ids: string[] }
        Returns: {
          created_at: string
          shipment_id: string
          order_id: string
          pudo_address: string
          pudo_city: string
          pudo_cp: string
          pudo_id: string
          pudo_name: string
          pudo_province: string
          set_dim: string
          set_id: string
          set_name: string
          set_ref: string
          set_weight: number
          user_email: string
          user_id: string
          user_name: string
          user_phone: string
        }[]
      }
      confirm_qr_validation: {
        Args: { p_qr_code: string; p_validated_by?: string }
        Returns: {
          message: string
          shipment_id: string
          success: boolean
        }[]
      }
      delete_assignment_and_rollback: {
        Args: { p_envio_id: string }
        Returns: undefined
      }
      generate_delivery_qr: {
        Args: { p_shipment_id: string }
        Returns: {
          expires_at: string
          qr_code: string
        }[]
      }
      generate_qr_code: { Args: never; Returns: string }
      generate_return_qr: {
        Args: { p_shipment_id: string }
        Returns: {
          expires_at: string
          qr_code: string
        }[]
      }
      has_role: {
        Args: {
          _role: Database["public"]["Enums"]["app_role"]
          _user_id: string
        }
        Returns: boolean
      }
      increment_referral_credits: {
        Args: { p_amount?: number; p_user_id: string }
        Returns: undefined
      }
      preview_assign_sets_to_users: {
        Args: never
        Returns: {
          current_stock: number
          matches_wishlist: boolean
          set_id: string
          set_name: string
          set_price: number
          set_ref: string
          user_id: string
          user_name: string
        }[]
      }
      process_referral_credit: {
        Args: { p_referee_user_id: string }
        Returns: undefined
      }
      update_set_status_from_return: {
        Args: { p_envio_id?: string; p_new_status: string; p_set_id: string }
        Returns: undefined
      }
      uses_brickshare_pudo: { Args: { shipment_id: string }; Returns: boolean }
      validate_qr_code: {
        Args: { p_qr_code: string }
        Returns: {
          error_message: string
          is_valid: boolean
          shipment_id: string
          shipment_info: Json
          validation_type: string
        }[]
      }
    }
    Enums: {
      app_role: "admin" | "user" | "operador"
      operation_type:
        | "recepcion paquete"
        | "analisis_peso"
        | "deposito_fulfillment"
        | "higienizado"
        | "retorno_stock"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {
      app_role: ["admin", "user", "operador"],
      operation_type: [
        "recepcion paquete",
        "analisis_peso",
        "deposito_fulfillment",
        "higienizado",
        "retorno_stock",
      ],
    },
  },
} as const